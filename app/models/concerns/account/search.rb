# frozen_string_literal: true

module Account::Search
  extend ActiveSupport::Concern

  DISALLOWED_TSQUERY_CHARACTERS = /['?\\:‘’]/

  TEXT_SEARCH_RANKS = <<~SQL.squish
    (
        SETWEIGHT(TO_TSVECTOR('simple', accounts.display_name), 'A') ||
        SETWEIGHT(TO_TSVECTOR('simple', accounts.username), 'B') ||
        SETWEIGHT(TO_TSVECTOR('simple', COALESCE(accounts.domain, '')), 'C')
    )
  SQL

  REPUTATION_SCORE_FUNCTION = <<~SQL.squish
    (
        GREATEST(0, COALESCE(account_stats.followers_count, 0)) / (
            GREATEST(0, COALESCE(account_stats.following_count, 0)) + 1.0
        )
    )
  SQL

  FOLLOWERS_SCORE_FUNCTION = <<~SQL.squish
    LOG(
        GREATEST(0, COALESCE(account_stats.followers_count, 0)) + 2
    )
  SQL

  TIME_DISTANCE_FUNCTION = <<~SQL.squish
    (
        CASE
            WHEN account_stats.last_status_at IS NULL THEN 0
            ELSE EXP(
                -1.0 * (
                    (
                        GREATEST(0, ABS(EXTRACT(DAY FROM AGE(account_stats.last_status_at))) - 30.0)^2) /#{' '}
                        (2.0 * ((-1.0 * 30^2) / (2.0 * ln(0.3)))
                    )
                )
            )
        end
    )
  SQL

  BOOST = <<~SQL.squish
    (
        (#{REPUTATION_SCORE_FUNCTION} + #{FOLLOWERS_SCORE_FUNCTION} + #{TIME_DISTANCE_FUNCTION}) / 3.0
    )
  SQL

  ADVANCED_SEARCH_WITH_FOLLOWING = <<~SQL.squish
    WITH first_degree AS (
      SELECT target_account_id
      FROM follows
      WHERE account_id = :id
      UNION ALL
      SELECT :id
    )
    SELECT
      accounts.*,
      (count(f.id) + 1) * #{BOOST} * ts_rank_cd(#{TEXT_SEARCH_RANKS}, to_tsquery('simple', :tsquery), 32) AS rank
    FROM accounts
    LEFT OUTER JOIN follows AS f ON (accounts.id = f.account_id AND f.target_account_id = :id)
    LEFT JOIN account_stats ON accounts.id = account_stats.account_id
    WHERE accounts.id IN (SELECT * FROM first_degree)
      AND to_tsquery('simple', :tsquery) @@ #{TEXT_SEARCH_RANKS}
      AND accounts.suspended_at IS NULL
      AND accounts.moved_to_account_id IS NULL
    GROUP BY accounts.id, account_stats.id
    ORDER BY rank DESC
    LIMIT :limit OFFSET :offset
  SQL

  ADVANCED_SEARCH_WITHOUT_FOLLOWING = <<~SQL.squish
    SELECT
      accounts.*,
      #{BOOST} * ts_rank_cd(#{TEXT_SEARCH_RANKS}, to_tsquery('simple', :tsquery), 32) AS rank,
      count(f.id) AS followed
    FROM accounts
    LEFT OUTER JOIN follows AS f ON
      (accounts.id = f.account_id AND f.target_account_id = :id) OR (accounts.id = f.target_account_id AND f.account_id = :id)
    LEFT JOIN users ON accounts.id = users.account_id
    LEFT JOIN account_stats ON accounts.id = account_stats.account_id
    WHERE to_tsquery('simple', :tsquery) @@ #{TEXT_SEARCH_RANKS}
      AND accounts.suspended_at IS NULL
      AND accounts.moved_to_account_id IS NULL
      AND (accounts.domain IS NOT NULL OR (users.approved = TRUE AND users.confirmed_at IS NOT NULL))
    GROUP BY accounts.id, account_stats.id
    ORDER BY followed DESC, rank DESC
    LIMIT :limit OFFSET :offset
  SQL

  DEFAULT_LIMIT = 10

  def searchable_text
    PlainTextFormatter.new(note, local?).to_s if discoverable?
  end

  def searchable_properties
    [].tap do |properties|
      properties << 'bot' if bot?
      properties << 'verified' if fields.any?(&:verified?)
      properties << 'discoverable' if discoverable?
    end
  end

  class_methods do
    def search_for(terms, limit: DEFAULT_LIMIT, offset: 0)
      left_joins(:user, :account_stat)
        .without_suspended
        .where(moved_to_account_id: nil)
        .remote.or(User.approved.confirmed)
        .where(terms_query(terms))
        .select(
          Account.arel_table[Arel.star],
          terms_rank(terms).as('rank')
        )
        .limit(limit)
        .order(rank: :desc)
        .offset(offset)
    end

    def terms_rank(terms)
      Arel.sql(
        sanitize_sql([<<~SQL.squish, tsquery: generate_query_for_search(terms)])
          #{BOOST} * TS_RANK_CD(#{TEXT_SEARCH_RANKS}, TO_TSQUERY('simple', :tsquery), 32)
        SQL
      )
    end

    def terms_query(terms)
      Arel.sql(
        sanitize_sql([<<~SQL.squish, tsquery: generate_query_for_search(terms)])
          TO_TSQUERY('simple', :tsquery) @@ #{TEXT_SEARCH_RANKS}
        SQL
      )
    end

    def advanced_search_for(terms, account, limit: DEFAULT_LIMIT, following: false, offset: 0)
      tsquery = generate_query_for_search(terms)
      sql_template = following ? ADVANCED_SEARCH_WITH_FOLLOWING : ADVANCED_SEARCH_WITHOUT_FOLLOWING

      find_by_sql([sql_template, { id: account.id, limit: limit, offset: offset, tsquery: tsquery }]).tap do |records|
        ActiveRecord::Associations::Preloader.new(records: records, associations: [:account_stat, { user: :role }]).call
      end
    end

    private

    def generate_query_for_search(unsanitized_terms)
      terms = unsanitized_terms.gsub(DISALLOWED_TSQUERY_CHARACTERS, ' ')

      # The final ":*" is for prefix search.
      # The trailing space does not seem to fit any purpose, but `to_tsquery`
      # behaves differently with and without a leading space if the terms start
      # with `./`, `../`, or `.. `. I don't understand why, so, in doubt, keep
      # the same query.
      "' #{terms} ':*"
    end
  end
end
