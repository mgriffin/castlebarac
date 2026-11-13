# frozen_string_literal: true

require "test_helper"

class EntryLineTest < ActiveSupport::TestCase
  setup do
    @entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
  end

  test "enters an eligible athlete" do
    line = @entry.entry_lines.create(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))

    assert_predicate line, :persisted?
    assert_equal 500, @entry.reload.total_cents
  end

  test "can't enter an ineligible athlete" do
    line = @entry.entry_lines.create(person: people(:liam), competition_event: competition_events(:u12_girls_600m))

    assert_includes line.errors[:person], "can't enter this event"
  end

  test "can't enter the same athlete into an event twice, even from another user" do
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    other = Entry.create!(competition: competitions(:connacht), user: users(:gabby))
    line = other.entry_lines.create(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))

    assert_includes line.errors[:competition_event_id], "already has this person entered"
  end

  test "can't go over the event limit" do
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_long_jump))
    line = @entry.entry_lines.create(person: people(:ciara), competition_event: competition_events(:u12_girls_80m))

    assert_includes line.errors[:base], "Ciara can only be entered into 2 events"
  end

  test "the event limit is per athlete" do
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_long_jump))
    line = @entry.entry_lines.create(person: people(:liam), competition_event: competition_events(:u12_boys_600m))

    assert_predicate line, :persisted?
  end

  test "can't enter after the closing date" do
    entry = Entry.create!(competition: competitions(:nationals), user: users(:bugs))
    line = entry.entry_lines.create(person: people(:ciara),
                                    competition_event: competition_events(:nationals_u12_girls_600m))

    assert_includes line.errors[:base], "Entries for this competition are closed"
  end

  test "the event has to be part of the competition" do
    line = @entry.entry_lines.create(person: people(:ciara),
                                     competition_event: competition_events(:nationals_u12_girls_600m))

    assert_includes line.errors[:competition_event], "isn't part of this competition"
  end
end
