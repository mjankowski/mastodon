# frozen_string_literal: true

class StatusTrend < ApplicationRecord
  include RankedTrend

  belongs_to :status
  belongs_to :account

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
  scope :with_account_constraint, -> { joins(account_constraint_joins_sql) }

  def self.account_constraint_joins_sql
    <<~SQL.squish
      INNER JOIN (
        SELECT account_id, MAX(score) AS max_score
        FROM status_trends
        GROUP BY account_id
      ) AS grouped_status_trends
      ON status_trends.account_id = grouped_status_trends.account_id
        AND status_trends.score = grouped_status_trends.max_score
    SQL
  end
end
