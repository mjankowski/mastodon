# frozen_string_literal: true

class FollowRecommendation < ApplicationRecord
  include DatabaseViewRecord

  self.primary_key = :account_id
  self.table_name = :global_follow_recommendations

  belongs_to :account_summary, foreign_key: :account_id, inverse_of: false
  belongs_to :account

  scope :localized, ->(locale) { joins(:account_summary).merge(AccountSummary.localized(locale)) }
end
