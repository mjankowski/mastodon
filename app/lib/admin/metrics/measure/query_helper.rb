# frozen_string_literal: true

module Admin::Metrics::Measure::QueryHelper
  protected

  def perform_data_query
    measurement_data_rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end

  def measurement_data_rows
    ActiveRecord::Base.connection.select_all(axis_results)
  end

  def axis_results
    axis_table
      .project(axis_table[Arel.star])
      .project(data_source_value)
      .from(axis_date_series)
      .to_sql
  end

  def select_target
    Arel.star.count.to_sql
  end

  def matching_day(model, column)
    <<~SQL.squish
      DATE_TRUNC('day', #{model.table_name}.#{column})::date = axis.period
    SQL
  end

  def account_domain_scope
    if params[:include_subdomains]
      Account.by_domain_and_subdomains(params[:domain])
    else
      Account.with_domain(params[:domain])
    end
  end

  def axis_table
    Arel::Table.new('axis')
  end

  def data_source_value
    Arel.sql(<<~SQL.squish)
      (WITH data_source AS (#{data_source.to_sql}) SELECT #{select_target} FROM data_source) AS value
    SQL
  end

  def axis_date_series
    Arel.sql(<<~SQL.squish)
      (SELECT GENERATE_SERIES('#{@start_at.to_fs(:db)}'::timestamp, '#{@end_at.to_fs(:db)}'::timestamp, '1 day')::date AS period) AS axis
    SQL
  end
end
