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
      Arel.sql(<<~SQL.squish)
        #{BOOST} * TS_RANK_CD(#{TEXT_SEARCH_RANKS}, #{simple_tsquery(terms)}, 32)
      SQL
    end

    def following_terms_rank(terms)
      Arel.sql(<<~SQL.squish)
        (COUNT(follows.id) + 1) * #{terms_rank(terms)}
      SQL
    end

    def terms_query(terms)
      Arel.sql(<<~SQL.squish)
        #{simple_tsquery(terms)} @@ #{TEXT_SEARCH_RANKS}
      SQL
    end

    def simple_tsquery(terms)
      Arel.sql(
        sanitize_sql([<<~SQL.squish, tsquery: generate_query_for_search(terms)])
          TO_TSQUERY('simple', :tsquery)
        SQL
      )
    end

    def advanced_search_for(terms, account, limit: DEFAULT_LIMIT, following: false, offset: 0)
      result = if following
                 advanced_search_with_following(terms, account, limit, offset)
               else
                 advanced_search_without_following(terms, account, limit, offset)
               end

      result.tap do |records|
        ActiveRecord::Associations::Preloader.new(
          records: records,
          associations: [:account_stat, { user: :role }]
        ).call
      end
    end

    def first_degree(account)
      Arel.sql(<<~SQL.squish)
        SELECT target_account_id
        FROM follows
        WHERE account_id = #{account.id}
        UNION ALL
        SELECT #{account.id}
      SQL
    end

    def advanced_search_with_following(terms, account, limit, offset)
      with(first_degree: first_degree(account))
        .left_joins(:account_stat)
        .joins(<<~SQL.squish)
          LEFT OUTER JOIN follows ON (accounts.id = follows.account_id AND follows.target_account_id = #{account.id})
        SQL
        .where('accounts.id IN (SELECT * FROM first_degree)')
        .where(terms_query(terms))
        .without_suspended
        .where(moved_to_account_id: nil)
        .select(
          Account.arel_table[Arel.star],
          following_terms_rank(terms).as('rank')
        )
        .group(Account.arel_table[:id], AccountStat.arel_table[:id])
        .limit(limit)
        .order(rank: :desc)
        .offset(offset)
    end

    def advanced_search_without_following(terms, account, limit, offset)
      left_joins(:user, :account_stat)
        .joins(<<~SQL.squish)
          LEFT OUTER JOIN follows ON
          (follows.account_id = accounts.id AND follows.target_account_id = #{account.id}) OR
          (follows.target_account_id = accounts.id AND follows.account_id = #{account.id})
        SQL
        .without_suspended
        .where(moved_to_account_id: nil)
        .remote.or(User.approved.confirmed)
        .where(terms_query(terms))
        .select(
          Account.arel_table[Arel.star],
          terms_rank(terms).as('rank'),
          Follow.arel_table[:id].count.as('follows_count')
        )
        .group(Account.arel_table[:id], AccountStat.arel_table[:id])
        .limit(limit)
        .order(follows_count: :desc, rank: :desc)
        .offset(offset)
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
