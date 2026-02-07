# frozen_string_literal: true

class ActivitySubscriber
  def emit(event)
    case event[:name]

    when 'interaction'
      ActivityTracker.increment('activity:interactions')
    else
      raise ArgumentError, "Invalid activity type: #{name}"
    end
  end
end

Rails.event.subscribe(ActivitySubscriber.new) { |event| event[:tags].key?(:activity) }
