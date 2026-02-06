# frozen_string_literal: true

class ActionLogSubscriber
  def emit(event)
    Admin::ActionLog.create(
      event[:payload].merge(
        account_id: event[:context][:account_id],
        action: event[:name]
      )
    )
  end
end

Rails.event.subscribe(ActionLogSubscriber.new) { |event| event[:tags].key?(:action_logs) }
