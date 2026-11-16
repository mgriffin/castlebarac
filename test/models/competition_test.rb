# frozen_string_literal: true

require "test_helper"

class CompetitionTest < ActiveSupport::TestCase
  test "accepts entries while open and before the closing date" do
    assert_predicate competitions(:connacht), :accepting_entries?
    assert_not competitions(:connacht).accepting_entries?(competitions(:connacht).entries_close_at)
  end

  test "doesn't accept entries after the closing date" do
    assert_predicate competitions(:nationals), :entries_open?
    assert_not competitions(:nationals).accepting_entries?
  end

  test "doesn't accept entries before they're opened" do
    assert_not competitions(:county).accepting_entries?
  end

  test "entries must close on or before the day of the competition" do
    competition = competitions(:connacht)
    competition.entries_close_at = competition.date + 1.day

    assert_not competition.valid?
    assert_includes competition.errors[:entries_close_at], "must be on or before the day of the competition"
  end

  test "makes a slug from the date and name" do
    competition = Competition.create!(name: "Mayo Indoors", level: "regional", date: Date.new(2027, 2, 1),
                                      entries_close_at: Time.zone.local(2027, 1, 20))

    assert_equal "2027-02-01-mayo-indoors", competition.slug
  end

  test "can't open entries without events or a fee" do
    competition = competitions(:county)

    assert_not competition.open_entries
    assert_includes competition.errors[:base], "Add at least one event before opening entries"
    assert_includes competition.errors[:base], "Set the fee per event before opening entries"
    assert_predicate competition.reload, :entries_draft?
  end

  test "opens entries" do
    competition = competitions(:county)
    competition.update!(fee_per_event: "4.50")
    competition.competition_events.create!(name: "U14 Boys 800m")

    assert competition.open_entries
    assert_predicate competition.reload, :entries_open?
    assert_equal 450, competition.fee_per_event_cents
  end

  test "can't open entries once the closing date has passed" do
    competition = competitions(:nationals)
    competition.entries_draft!

    assert_not competition.open_entries
    assert_includes competition.errors[:entries_close_at], "must be in the future to open entries"
  end

  test "age groups go by age on 31 December" do
    assert_equal Date.new(competitions(:connacht).date.year, 12, 31), competitions(:connacht).age_reference_date
  end
end
