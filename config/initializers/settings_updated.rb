# frozen_string_literal: true

Rails.configuration.after_initialize do
  Rails.application.config.x.settings_updated_at = Setting.order(updated_at: :desc).pick(:updated_at) || Time.current
end
