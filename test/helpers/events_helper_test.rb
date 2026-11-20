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

  test "draws a date tile" do
    tile = date_tile(Time.zone.local(2026, 5, 16, 10))

    assert_dom_equal(
      '<time class="date-tile" datetime="2026-05-16"><span class="date-tile__month">May</span>' \
      '<span class="date-tile__day">16</span></time>',
      tile
    )
    assert_includes date_tile(Time.zone.local(2026, 5, 16), large: true), "date-tile--large"
  end
end
