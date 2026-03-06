# frozen_string_literal: true

class PollExpirationValidator < ActiveModel::Validator
  MAX_EXPIRATION = 1.month.freeze
  MIN_EXPIRATION = 5.minutes.freeze

  def validate(poll)
    # We have a `presence: true` check for this attribute already
    return if poll.expires_at.nil?

    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_long')) if duration_too_long?(poll)
    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_short')) if duration_too_short?(poll)
  end

  private

  def duration_too_long?(poll)
    poll.expires_at > MAX_EXPIRATION.from_now
  end

  def duration_too_short?(poll)
    poll.expires_at < MIN_EXPIRATION.from_now
  end
end
