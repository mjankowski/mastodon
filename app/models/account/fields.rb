# frozen_string_literal: true

module Account::Fields
  extend ActiveSupport::Concern

  DEFAULT_FIELDS_SIZE = 4

  included do
    validates :fields, length: { maximum: DEFAULT_FIELDS_SIZE }, if: -> { local? && will_save_change_to_fields? }
    validates_with EmptyProfileFieldNamesValidator, if: -> { local? && will_save_change_to_fields? }
  end

  def fields
    (self[:fields] || []).filter_map do |f|
      Account::Field.new(self, f)
    rescue
      nil
    end
  end

  def fields_attributes=(attributes)
    fields     = []
    old_fields = self[:fields] || []
    old_fields = [] if old_fields.is_a?(Hash)

    attributes = attributes.values if attributes.is_a?(Hash)

    attributes.each do |attr|
      next if attr[:name].blank? && attr[:value].blank?

      previous = old_fields.find { |item| item['value'] == attr[:value] }

      attr[:verified_at] = previous['verified_at'] if previous && previous['verified_at'].present?

      fields << attr
    end

    self[:fields] = fields
  end

  def build_fields
    return if fields.size >= DEFAULT_FIELDS_SIZE

    tmp = self[:fields] || []
    tmp = [] if tmp.is_a?(Hash)

    (DEFAULT_FIELDS_SIZE - tmp.size).times do
      tmp << { name: '', value: '' }
    end

    self.fields = tmp
  end
end
