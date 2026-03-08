# frozen_string_literal: true

module Tag::Naming
  extend ActiveSupport::Concern

  HASHTAG_SEPARATORS = "_\u00B7\u30FB\u200c"
  HASHTAG_FIRST_SEQUENCE_CHUNK_ONE = "[[:word:]_][[:word:]#{HASHTAG_SEPARATORS}]*[[:alpha:]#{HASHTAG_SEPARATORS}]".freeze
  HASHTAG_FIRST_SEQUENCE_CHUNK_TWO = "[[:word:]#{HASHTAG_SEPARATORS}]*[[:word:]_]".freeze
  HASHTAG_FIRST_SEQUENCE = "(#{HASHTAG_FIRST_SEQUENCE_CHUNK_ONE}#{HASHTAG_FIRST_SEQUENCE_CHUNK_TWO})".freeze
  HASHTAG_LAST_SEQUENCE = '([[:word:]_]*[[:alpha:]][[:word:]_]*)'
  HASHTAG_NAME_PAT = "#{HASHTAG_FIRST_SEQUENCE}|#{HASHTAG_LAST_SEQUENCE}".freeze

  HASHTAG_RE = /(?<=^|[[:space:]])[#＃](#{HASHTAG_NAME_PAT})/
  HASHTAG_NAME_RE = /\A(#{HASHTAG_NAME_PAT})\z/i
  HASHTAG_INVALID_CHARS_RE = /[^[:alnum:]\u0E47-\u0E4E#{HASHTAG_SEPARATORS}]/

  included do
    validates :name, presence: true, format: { with: HASHTAG_NAME_RE }
    validates :display_name, format: { with: HASHTAG_NAME_RE }

    validate :validate_name_change, on: :update, if: :name_changed?
    validate :validate_display_name_change, on: :update, if: :display_name_changed?

    normalizes :name, with: ->(value) { HashtagNormalizer.new.normalize(value) }
    normalizes :display_name, with: ->(value) { value.gsub(HASHTAG_INVALID_CHARS_RE, '') }

    scope :matches_name, ->(term) { where(arel_table[:name].lower.matches(matches_name_sanitize(term), nil, true)) }
  end

  class_methods do
    def find_or_create_by_names(name_or_names)
      names = Array(name_or_names).map { |str| [normalize_value_for(:name, str), str] }.uniq(&:first)

      names.map do |name, display_name|
        tag = begin
          matching_name(name).first || create!(name:, display_name:)
        rescue ActiveRecord::RecordNotUnique
          find_normalized(name)
        end

        yield tag if block_given?

        tag
      end
    end

    def matching_name(name_or_names)
      names = Array(name_or_names).map { |name| arel_table.lower(normalize_value_for(:name, name)) }

      if names.many?
        where(arel_table[:name].lower.in(names))
      else
        where(arel_table[:name].lower.eq(names.first))
      end
    end

    def matches_name_sanitize(term)
      arel_table.lower("#{sanitize_sql_like(normalize_value_for(:name, term))}%")
    end
  end

  def display_name
    attributes['display_name'] || name
  end

  def formatted_name
    "##{display_name}"
  end

  private

  def validate_name_change
    errors.add(:name, I18n.t('tags.does_not_match_previous_name')) unless name_was.casecmp(name).zero?
  end

  def validate_display_name_change
    errors.add(:display_name, I18n.t('tags.does_not_match_previous_name')) unless display_name_matches_name?
  end

  def display_name_matches_name?
    self.class.normalize_value_for(:name, display_name).casecmp(name).zero?
  end
end
