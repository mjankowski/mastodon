# frozen_string_literal: true

class Registration
  def self.mode
    ActiveSupport::StringInquirer.new Setting.registrations_mode
  end
end
