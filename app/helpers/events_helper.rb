# frozen_string_literal: true

module EventsHelper
  # e.g. "Monday, 11:00am", or just "Monday" for an event without a time,
  # which is stored as midnight
  def event_when(event)
    time = event.start_time
    return time.strftime("%A") if time.seconds_since_midnight.zero?

    time.strftime("%A, %-l:%M%P")
  end
end
