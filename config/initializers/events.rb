# frozen_string_literal: true

class ActivitySubscriber
  def emit(event)
    case event[:name]

    when 'interaction'
      ActivityTracker.increment('activity:interactions')
    when 'status'
      ActivityTracker.increment('activity:statuses:local')
    when 'account'
      ActivityTracker.increment('activity:accounts:local')
    when 'login'
      ActivityTracker.record('activity:logins', event[:payload][:id])
    else
      raise ArgumentError, "Invalid activity type: #{name}"
    end
  end
end

Rails.event.subscribe(ActivitySubscriber.new) { |event| event[:tags].key?(:activity) }
