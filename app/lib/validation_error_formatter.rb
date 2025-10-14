# frozen_string_literal: true

class ValidationErrorFormatter
  def initialize(error, aliases = {})
    @error   = error
    @aliases = aliases
  end

  def as_json
    { error: @error.to_s, details: details }
  end

  private

  def details
    grouped_errors.to_h do |attribute, errors|
      [label(attribute), summary(errors)]
    end
  end

  def label(attribute)
    @aliases[attribute] || attribute
  end

  def summary(errors)
    errors.map do |error|
      { error: code(error), description: error.message }
    end
  end

  def code(error)
    [:err, error.type.to_s].join('_').upcase
  end

  def grouped_errors
    @error.record.errors.group_by(&:attribute)
  end
end
