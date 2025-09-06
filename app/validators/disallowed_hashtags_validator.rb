# frozen_string_literal: true

class DisallowedHashtagsValidator < ActiveModel::Validator
  def validate(status)
    return unless status.local? && !status.reblog?

    disallowed_hashtags = Tag.matching_name(Extractor.extract_hashtags(status.text)).reject(&:usable?)
    status.errors.add(:text, disallowed_message(disallowed_hashtags)) unless disallowed_hashtags.empty?
  end

  private

  def disallowed_message(tags)
    I18n.t 'statuses.disallowed_hashtags', tags: tags.map(&:name).join(', '), count: tags.size
  end
end
