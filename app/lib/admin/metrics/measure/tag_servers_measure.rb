# frozen_string_literal: true

class Admin::Metrics::Measure::TagServersMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def self.with_params?
    true
  end

  def key
    'tag_servers'
  end

  protected

  def perform_total_query
    domain_tag_count id_range(@start_at, @end_at)
  end

  def perform_previous_total_query
    domain_tag_count id_range(@start_at, @end_at, length_of_period)
  end

  def data_source
    Status
      .select('accounts.domain')
      .distinct
      .reorder(nil)
      .joins(:tags, :account)
      .where(statuses_tags: { tag_id: tag.id })
      .where(status_range_sql, earliest_status_id: earliest_status_id, latest_status_id: latest_status_id)
      .where(daily_period(:statuses))
  end

  def earliest_status_id
    Mastodon::Snowflake.id_at(@start_at.beginning_of_day, with_random: false)
  end

  def latest_status_id
    Mastodon::Snowflake.id_at(@end_at.end_of_day, with_random: false)
  end

  def tag
    @tag ||= Tag.find(params[:id])
  end

  def params
    @params.permit(:id)
  end

  def domain_tag_count(range)
    tag
      .statuses
      .where(id: range)
      .joins(:account)
      .distinct
      .count(Account.arel_table[:domain])
  end

  def id_range(starting, ending, offset = 0)
    id_from(starting - offset)..id_from(ending - offset)
  end

  def id_from(time)
    Mastodon::Snowflake.id_at(time, with_random: false)
  end
end
