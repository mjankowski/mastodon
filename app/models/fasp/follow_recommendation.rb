# frozen_string_literal: true

class Fasp::FollowRecommendation < ApplicationRecord
  MAX_AGE = 1.day.freeze

  belongs_to :requesting_account, class_name: 'Account'
  belongs_to :recommended_account, class_name: 'Account'

  scope :outdated, -> { where(created_at: ...(MAX_AGE.ago)) }
  scope :for_account, ->(account) { where(requesting_account: account) }
  scope :newest_first, -> { order(created_at: :desc) }
end
