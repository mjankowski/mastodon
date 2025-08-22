# frozen_string_literal: true

# == Schema Information
#
# Table name: poll_votes
#
#  id         :bigint(8)        not null, primary key
#  choice     :integer          default(0), not null
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#  poll_id    :bigint(8)        not null
#

class PollVote < ApplicationRecord
  belongs_to :account
  belongs_to :poll, inverse_of: :votes

  validates :choice, presence: true
  validates_with VotingLimitsValidator
  validate :validate_poll_not_expired
  validate :validate_invalid_choice
  validate :validate_self_vote

  after_create_commit :increment_counter_cache

  delegate :local?, to: :account
  delegate :multiple?, :expired?, to: :poll, prefix: true

  def object_type
    :vote
  end

  private

  def increment_counter_cache
    poll.cached_tallies[choice] = (poll.cached_tallies[choice] || 0) + 1
    poll.save
  rescue ActiveRecord::StaleObjectError
    poll.reload
    retry
  end

  def validate_poll_not_expired
    errors.add(:base, I18n.t('polls.errors.expired')) if poll_expired?
  end

  def validate_invalid_choice
    errors.add(:base, I18n.t('polls.errors.invalid_choice')) if invalid_choice?
  end

  def validate_self_vote
    errors.add(:base, I18n.t('polls.errors.self_vote')) if self_vote?
  end

  def self_vote?
    account_id == poll.account_id
  end

  def invalid_choice?
    choice.negative? || choice >= poll.options.size
  end
end
