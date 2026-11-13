# frozen_string_literal: true

require "test_helper"

class CompetitionsHelperTest < ActionView::TestCase
  test "shows the years athletes in an event were born" do
    event = competition_events(:u12_girls_600m)
    year = event.competition.date.year

    assert_equal (year - 11).to_s, birth_years(event)

    event.min_age = 10

    assert_equal "#{year - 11}–#{year - 10}", birth_years(event)

    event.max_age = nil

    assert_equal "#{year - 10} or earlier", birth_years(event)

    event.min_age = nil

    assert_nil birth_years(event)
  end

  test "shows euros" do
    assert_equal "€5.50", euros(550)
  end
end
