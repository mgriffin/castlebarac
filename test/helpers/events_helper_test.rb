# frozen_string_literal: true

require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "shows the day and time of an event" do
    assert_equal "Monday, 11:00am", event_when(Event.new(start_time: Time.zone.local(2026, 11, 23, 11)))
    assert_equal "Saturday, 6:30pm", event_when(Event.new(start_time: Time.zone.local(2026, 12, 12, 18, 30)))
  end

  test "leaves out the time of an event without one" do
    assert_equal "Monday", event_when(Event.new(start_time: Time.zone.local(2026, 11, 23)))
  end
end
