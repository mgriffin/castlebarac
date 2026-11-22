# frozen_string_literal: true

require "test_helper"

class PeopleHelperTest < ActionView::TestCase
  test "membership years are run together" do
    assert_nil member_years_label([])
    assert_equal "Member 2026", member_years_label([2026])
    assert_equal "Member 2019, 2021–2026", member_years_label([2019, 2021, 2022, 2023, 2024, 2025, 2026])
  end

  test "a personal best needs more than one time" do
    fast = Result.new(seconds: 9.62)

    assert_nil personal_best([fast])
    assert_equal fast, personal_best([Result.new(seconds: 9.85), fast, Result.new(result: "DNF")])
  end
end
