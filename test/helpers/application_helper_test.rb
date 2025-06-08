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
end
