# frozen_string_literal: true

class Rule < ApplicationRecord
  include Discard::Model

  TEXT_SIZE_LIMIT = 300

  self.discard_column = :deleted_at

  has_many :translations, -> { order(language: :asc) }, inverse_of: :rule, class_name: 'RuleTranslation', dependent: :destroy
  accepts_nested_attributes_for :translations, reject_if: ->(attributes) { attributes['text'].blank? }, allow_destroy: true

  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }

  scope :ordered, -> { kept.order(priority: :asc, id: :asc) }

  def move!(offset)
    rules = Rule.ordered.to_a
    position = rules.index(self)

    rules.delete_at(position)
    rules.insert(position + offset, self)

    transaction do
      rules.each.with_index do |rule, index|
        rule.update!(priority: index)
      end
    end
  end

  def translation_for(locale)
    @cached_translations ||= {}
    @cached_translations[locale] ||= translations.for_locale(locale).by_language_length.first || translations.build(language: locale, text: text, hint: hint)
  end

  def untranslated_languages
    RuleTranslation.excluding(translations).languages
  end
end
