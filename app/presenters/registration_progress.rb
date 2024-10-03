# frozen_string_literal: true

class RegistrationProgress
  attr_reader :stage

  PROGRESS_STEPS = %w(rules details confirm confirmed completed).freeze

  def initialize(stage)
    @stage = ActiveSupport::StringInquirer.new(stage)
  end

  delegate(
    :rules?,
    :details?,
    :confirm?,
    :confirmed?,
    to: :stage,
    prefix: true
  )

  def completed?(query)
    PROGRESS_STEPS
      .drop(PROGRESS_STEPS.index(query.to_s) + 1)
      .include?(stage)
  end

  def to_partial_path
    'auth/shared/progress'
  end
end
