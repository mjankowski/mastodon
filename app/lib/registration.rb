# frozen_string_literal: true

class Registration
  MODES = %w(open approved none).freeze

  def self.mode
    Setting.registrations_mode.to_s.inquiry
  end

  def self.allowed?
    mode.approved? || mode.open?
  end
end
