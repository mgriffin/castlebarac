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

  test "an athlete of the right age and gender is eligible" do
    assert competition_events(:u12_girls_600m).eligible?(people(:ciara))
  end

  test "an athlete of the wrong gender isn't eligible" do
    assert_equal :gender, competition_events(:u12_girls_600m).ineligibility_reason(people(:liam))
  end

  test "mixed events are open to everyone of the right age" do
    event = competition_events(:u10_mixed_relay)
    event.update!(min_age: 11, max_age: 11)

    assert event.eligible?(people(:ciara))
    assert event.eligible?(people(:liam))
  end

  test "an athlete outside the age group isn't eligible" do
    assert_equal :too_old, competition_events(:u10_mixed_relay).ineligibility_reason(people(:ciara))

    people(:ciara).year = people(:ciara).birth_year + 2

    assert_equal :too_young, competition_events(:u12_girls_600m).ineligibility_reason(people(:ciara))
  end

  test "an athlete without a year of birth or gender needs those first" do
    assert_equal :missing_details, competition_events(:u10_mixed_relay).ineligibility_reason(people(:aoife))
  end
end
