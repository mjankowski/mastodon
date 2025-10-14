# frozen_string_literal: true

class ValidationErrorFormatter
  PREFIX = 'ERR'

  def initialize(error, aliases = {})
    @error   = error
    @aliases = aliases
  end

  def as_json
    { error: @error.to_s, details: }
  end

  private

  def details
    {}.tap do |detail|
      record_errors.group_by(&:attribute).each do |attribute, errors|
        detail[@aliases[attribute] || attribute] = errors.map do |error|
          { error: code(error), description: error.message }
        end
      end
    end
  end

  def code(error)
    [PREFIX, error.type.to_s.upcase].join('_')
  end

  def record_errors
    @record_errors ||= @error.record.errors
  end
end
