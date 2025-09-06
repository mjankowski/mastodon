# frozen_string_literal: true

class PollExpirationValidator < ActiveModel::Validator
  MAX_EXPIRATION = 1.month.freeze
  MIN_EXPIRATION = 5.minutes.freeze

  def validate(poll)
    # We have a `presence: true` check for this attribute already
    return if poll.expires_at.nil?

    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_long')) if poll.expires_at > MAX_EXPIRATION.from_now
    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_short')) if poll.expires_at < MIN_EXPIRATION.from_now
  end
end
