# frozen_string_literal: true

require "test_helper"

class PeopleHelperTest < ActionView::TestCase
  test "times are shown without leading zeros" do
    assert_equal "9.85", result_mark(Result.new(seconds: 9.85))
    assert_equal "12.3", result_mark(Result.new(seconds: 12.3))
    assert_equal "4:31", result_mark(Result.new(seconds: 271))
    assert_equal "1:02:05.4", result_mark(Result.new(seconds: 3725.4))
  end

  test "anything that isn't a time is shown as the results have it" do
    assert_equal "3.22", result_mark(Result.new(seconds: -3.22, result: "3.22"))
    assert_equal "DNF", result_mark(Result.new(result: "DNF"))
    assert_equal "–", result_mark(Result.new)
  end

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
