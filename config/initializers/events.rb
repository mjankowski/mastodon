# frozen_string_literal: true

class ActionLogSubscriber
  def emit(event)
    Admin::ActionLog.create(
      event[:payload]
        .merge(action: event[:name])
        .merge(event[:context].slice(:account_id))
    )
  end
end

Rails.event.subscribe(ActionLogSubscriber.new) { |event| event[:tags].key?(:action_logs) }
