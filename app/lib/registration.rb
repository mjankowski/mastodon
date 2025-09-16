# frozen_string_literal: true

class Registration
  def self.mode
    Setting.registrations_mode.to_s.inquiry
  end

  def self.allowed?
    !mode.none? # rubocop:disable Style/InverseMethods
  end
end
