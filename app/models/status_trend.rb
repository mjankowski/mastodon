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

  scope :allowed, -> { joins(max_trend_score_joins).where(allowed: true) }

  def self.max_trend_score_joins
    Arel.sql(<<~SQL.squish)
      INNER JOIN (
        SELECT
          account_id,
          MAX(score) AS max_score
        FROM
          status_trends
        GROUP BY
          account_id
      ) AS grouped_status_trends ON status_trends.account_id = grouped_status_trends.account_id
      AND status_trends.score = grouped_status_trends.max_score
    SQL
  end
end
