# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceMediaAttachmentsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper
  include ActionView::Helpers::NumberHelper

  def self.with_params?
    true
  end

  def key
    'instance_media_attachments'
  end

  def unit
    'bytes'
  end

  def value_to_human_value(value)
    number_to_human_size(value)
  end

  def total_in_time_range?
    false
  end

  protected

  def perform_total_query
    domain = params[:domain]
    domain = Instance.by_domain_and_subdomains(params[:domain]).select(:domain) if params[:include_subdomains]
    MediaAttachment.joins(:account).merge(Account.where(domain: domain)).sum(MediaAttachment.combined_media_file_size)
  end

  def perform_previous_total_query
    nil
  end

  def data_source
    MediaAttachment
      .select(media_size_total)
      .joins(:account)
      .merge(account_domain_scope)
      .where(matching_day(MediaAttachment, :created_at))
  end

  def select_target
    MediaAttachment.arel_table.coalesce(Arel.sql("SUM(#{media_size_name})"), 0).to_sql
  end

  def media_size_total
    MediaAttachment.combined_media_file_size.as(media_size_name)
  end

  def media_size_name
    'size'
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end
