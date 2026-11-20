# frozen_string_literal: true

module EventsHelper
  # e.g. "Monday, 11:00am", or just "Monday" for an event without a time,
  # which is stored as midnight
  def event_when(event)
    time = event.start_time
    return time.strftime("%A") if time.seconds_since_midnight.zero?

    time.strftime("%A, %-l:%M%P")
  end

  # A small calendar page showing the month and day
  def date_tile(time, large: false)
    tag.time(class: class_names("date-tile", "date-tile--large": large), datetime: time.to_date.iso8601) do
      tag.span(time.strftime("%b"), class: "date-tile__month") +
        tag.span(time.day, class: "date-tile__day")
    end
  end
end
