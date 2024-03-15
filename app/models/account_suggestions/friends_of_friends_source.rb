# frozen_string_literal: true

class AccountSuggestions::FriendsOfFriendsSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    source_query(account, limit: limit)
      .map { |id, _frequency, _followers_count| [id, key] }
  end

  def source_query(account, limit: DEFAULT_LIMIT)
    base_account_scope(account)
      .joins(:account_stat)
      .with(first_degree: account.following.where.not(hide_collections: true).select(:id).reorder(nil))
      .joins(first_degree_follows_join)
      .group('accounts.id, account_stats.id')
      .reorder(frequency: :desc, followers_count: :asc)
      .limit(limit)
      .pluck(Arel.sql('accounts.id, COUNT(*) AS frequency, followers_count'))
  end

  private

  def first_degree_follows_join
    Arel.sql(
      <<~SQL.squish
        JOIN follows first_degree_follows ON first_degree_follows.target_account_id = accounts.id
          AND first_degree_follows.account_id IN (SELECT * FROM first_degree)
      SQL
    )
  end

  def key
    :friends_of_friends
  end
end
