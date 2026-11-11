# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  [
    [60, "60m"],
    [100, "100m"],
    [5000, "5km"],
    [10_000, "10km"]
  ].each do |input, expected|
    test "distance_to_human for #{input} metres" do
      actual = distance_to_human(input)
      assert_dom_equal expected, actual, "Expected #{input} metres to be formatted as #{expected}, but it was #{actual}"
    end
  end

  test "time_ago_tag shows how long ago with the full date as a title" do
    travel_to Time.zone.local(2026, 11, 11, 12, 0) do
      tag = time_ago_tag(Time.zone.local(2026, 11, 8, 9, 30))

      assert_dom_equal %(<time datetime="2026-11-08T09:30:00Z" title="November 08, 2026 09:30">3 days ago</time>), tag
    end
  end

  test "time_ago_tag is empty without a time" do
    assert_nil time_ago_tag(nil)
  end
end
