# frozen_string_literal: true

class TagFollow < ApplicationRecord
  include RateLimitable
  include Paginable

  belongs_to :tag
  belongs_to :account

  accepts_nested_attributes_for :tag

  rate_limit by: :account, family: :follows

  scope :for_local_distribution, -> { joins(account: :user).merge(User.signed_in_recently) }
end
