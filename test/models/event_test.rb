# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  [
    [Time.zone.local(2025, 1, 1, 0, 0, 0), "January 1st 2025"],
    [Time.zone.local(2025, 1, 2, 0, 0, 0), "January 2nd 2025"],
    [Time.zone.local(2025, 1, 3, 0, 0, 0), "January 3rd 2025"],
    [Time.zone.local(2025, 1, 4, 0, 0, 0), "January 4th 2025"],
    [Time.zone.local(2025, 1, 5, 0, 0, 0), "January 5th 2025"],
    [Time.zone.local(2025, 1, 10, 0, 0, 0), "January 10th 2025"],
    [Time.zone.local(2025, 1, 11, 0, 0, 0), "January 11th 2025"]
  ].each do |start_time, expected|
    test "human_date should output #{expected}" do
      event = Event.build(start_time:)

      assert_equal expected, event.human_date
    end
  end
end
