# frozen_string_literal: true

class Registration
  def self.mode
    ActiveSupport::StringInquirer.new Setting.registrations_mode
  end

  def self.enabled?
    !mode.none? # rubocop:disable Style/InverseMethods
  end
end
