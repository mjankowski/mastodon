# frozen_string_literal: true

class PollOptionsValidator < ActiveModel::Validator
  MAX_OPTIONS      = 4
  MAX_OPTION_CHARS = 50

  def validate(poll)
    poll.errors.add(:options, too_few_message) unless poll.options.size > 1
    poll.errors.add(:options, too_many_message) if poll.options.size > MAX_OPTIONS
    poll.errors.add(:options, character_limit_message) if poll.options.any? { |option| option.each_grapheme_cluster.size > MAX_OPTION_CHARS }
    poll.errors.add(:options, duplicate_message) unless poll.options.uniq.size == poll.options.size
  end

  private

  def too_few_message
    I18n.t('polls.errors.too_few_options')
  end

  def too_many_message
    I18n.t('polls.errors.too_many_options', max: MAX_OPTIONS)
  end

  def character_limit_message
    I18n.t('polls.errors.over_character_limit', max: MAX_OPTION_CHARS)
  end

  def duplicate_message
    I18n.t('polls.errors.duplicate_options')
  end
end
