# frozen_string_literal: true

# == Schema Information
#
# Table name: status_trends
#
#  id         :bigint(8)        not null, primary key
#  status_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  score      :float            default(0.0), not null
#  rank       :integer          default(0), not null
#  allowed    :boolean          default(FALSE), not null
#  language   :string
#

class StatusTrend < ApplicationRecord
  include RankedTrend

  belongs_to :status
  belongs_to :account

  scope :allowed, lambda {
    joins(<<~SQL.squish).where(allowed: true)
      INNER JOIN (#{max_scores_by_account.to_sql}) AS grouped_status_trends
      ON status_trends.account_id = grouped_status_trends.account_id
      AND status_trends.score = grouped_status_trends.max_score
    SQL
  }

  def self.max_scores_by_account
    select(:account_id, arel_table[:score].maximum.as('max_score')).group(:account_id)
  end
end
