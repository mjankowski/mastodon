# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  def log_event(name, target)
    Rails.event.tagged :action_logs do
      Rails.event.notify(name, target_id: target.id, target_type: target.class.name)
    end
  end

  def log_action(action, target)
    current_account
      .action_logs
      .create(action:, target:)
  end
end
