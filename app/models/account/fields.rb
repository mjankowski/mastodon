# frozen_string_literal: true

module Account::Fields
  extend ActiveSupport::Concern

  DEFAULT_FIELDS_SIZE = 4

  included do
    with_options if: [:local?, :will_save_change_to_fields?] do
      validates :fields, length: { maximum: DEFAULT_FIELDS_SIZE }
      validates_with EmptyProfileFieldNamesValidator
    end
  end

  def fields
    Array(self[:fields]).filter_map do |field|
      Account::Field.new(self, field)
    rescue
      nil
    end
  end

  def fields_attributes=(attributes)
    attributes = attributes.values if attributes.is_a?(Hash)

    self[:fields] = [].tap do |fields|
      attributes.each do |attr|
        next if attr[:name].blank? && attr[:value].blank?

        normalized_previous_fields
          .find { |field| field['value'] == attr[:value] }
          .tap { |previous| attr[:verified_at] = previous && previous['verified_at'].presence }

        fields << attr
      end
    end
  end

  def build_fields
    return if fields.size >= DEFAULT_FIELDS_SIZE

    self.fields = normalized_previous_fields + additional_fields
  end

  def additional_fields
    Array.new(DEFAULT_FIELDS_SIZE - normalized_previous_fields.size) { %i(name value).index_with('') }
  end

  def normalized_previous_fields
    @normalized_previous_fields ||= Array(self[:fields].is_a?(Hash) ? nil : self[:fields])
  end
end
