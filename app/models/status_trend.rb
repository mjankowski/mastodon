# frozen_string_literal: true

# == Schema Information
#
# Table name: status_trends
#
#  id         :bigint(8)        not null, primary key
#  allowed    :boolean          default(FALSE), not null
#  language   :string
#  rank       :integer          default(0), not null
#  score      :float            default(0.0), not null
#  account_id :bigint(8)        not null
#  status_id  :bigint(8)        not null
#

class StatusTrend < ApplicationRecord
  include RankedTrend

  belongs_to :status
  belongs_to :account

  scope :allowed, -> { by_max_rank.where(allowed: true) }

  def self.by_max_rank
    with(max_scores: select(:account_id, arel_table[:score].maximum.as('max_score')).group(:account_id))
      .joins(<<~SQL.squish)
        JOIN max_scores ON status_trends.account_id = max_scores.account_id AND status_trends.score = max_scores.max_score
      SQL
  end
end
