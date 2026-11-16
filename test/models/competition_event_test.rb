# frozen_string_literal: true

require "test_helper"

class CompetitionEventTest < ActiveSupport::TestCase
  test "works out the ages from an under-age group" do
    event = competitions(:connacht).competition_events.create!(name: "U14 Girls 800m", age_group: "U14")

    assert_equal [13, 13], [event.min_age, event.max_age]
  end

  test "keeps ages that are given" do
    event = competitions(:connacht).competition_events.create!(name: "U14 Girls 800m", age_group: "U14",
                                                               min_age: 12, max_age: 13)

    assert_equal [12, 13], [event.min_age, event.max_age]
  end

  test "the maximum age can't be below the minimum" do
    event = CompetitionEvent.new(competition: competitions(:connacht), name: "Odd", min_age: 12, max_age: 10)

    assert_not event.valid?
    assert_includes event.errors[:max_age], "must be at least the minimum age"
  end
end
