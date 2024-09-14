# frozen_string_literal: true

class AnnualReport::Percentiles < AnnualReport::Source
  def generate
    {
      percentiles: {
        followers: (total_with_fewer_followers / (total_with_any_followers + 1.0)) * 100,
        statuses: (total_with_fewer_statuses / (total_with_any_statuses + 1.0)) * 100,
      },
    }
  end

  private

  def followers_gained
    @followers_gained ||= @account.passive_relationships.where("date_part('year', follows.created_at) = ?", @year).count
  end

  def statuses_created
    @statuses_created ||= report_statuses.count
  end

  def total_with_fewer_followers
    @total_with_fewer_followers ||= fewer_followers.to_a.first.total
  end

  def total_with_fewer_statuses
    @total_with_fewer_statuses ||= fewer_statuses.to_a.first.total
  end

  def fewer_followers
    Follow
      .with(under_threshold_follows:)
      .from('under_threshold_follows')
      .select(Arel.star.count.as('total'))
  end

  def fewer_statuses
    Status
      .unscoped # Remove the default order and `kept` conditions
      .with(under_threshold_statuses:)
      .from('under_threshold_statuses')
      .select(Arel.star.count.as('total'))
  end

  def under_threshold_follows
    Follow
      .joins(:account)
      .merge(Account.local)
      .where(<<~SQL.squish, year: @year)
        DATE_PART('year', follows.created_at)::int = :year
      SQL
      .group(:target_account_id)
      .having(Arel.star.count.lt(followers_gained))
      .select(:target_account_id)
  end

  def under_threshold_statuses
    Status
      .unscoped # Remove the default order and `kept` conditions
      .joins(:account)
      .merge(Account.local)
      .where(statuses: { id: year_as_snowflake_range.first..year_as_snowflake_range.last })
      .group(:account_id)
      .having(Arel.star.count.lt(statuses_created))
      .select(:account_id)
  end

  def total_with_any_followers
    @total_with_any_followers ||= Follow.where("date_part('year', follows.created_at) = ?", @year).joins(:target_account).merge(Account.local).count('distinct follows.target_account_id')
  end

  def total_with_any_statuses
    @total_with_any_statuses ||= Status.where(id: year_as_snowflake_range).joins(:account).merge(Account.local).count('distinct statuses.account_id')
  end
end
