# frozen_string_literal: true

# One person entered into one event
class EntryLine < ApplicationRecord
  belongs_to :entry
  belongs_to :person
  belongs_to :competition_event

  validates :competition_event_id, uniqueness: { scope: :person_id }
  validate :event_is_in_competition
  validate :competition_accepting_entries, on: :create
  validate :person_eligible
  validate :within_event_limit, on: :create

  delegate :competition, to: :entry

  # Lines for this person in this competition, whoever entered them
  scope :for_person_in, lambda { |person, competition|
    joins(:competition_event).where(person:, competition_events: { competition_id: competition.id })
  }

  private

  def event_is_in_competition
    return if competition_event.nil? || entry.nil?
    return if competition_event.competition_id == entry.competition_id

    errors.add(:competition_event, :not_in_competition)
  end

  def competition_accepting_entries
    return if entry.nil? || competition.accepting_entries?

    errors.add(:base, :entries_closed)
  end

  def person_eligible
    return if person.nil? || competition_event.nil?

    reason = competition_event.ineligibility_reason(person)
    errors.add(:person, reason) if reason
  end

  # Two parents entering the same child at once can't both get under the
  # limit: SQLite has one writer at a time, and this runs inside the
  # transaction that saves the line (Rails starts SQLite transactions with
  # BEGIN IMMEDIATE), so the second count waits for the first save.
  def within_event_limit
    return if person.nil? || entry.nil?

    limit = competition.max_events_per_athlete
    return if limit.nil?
    return if EntryLine.for_person_in(person, competition).count < limit

    errors.add(:base, :event_limit, count: limit, name: person.firstname)
  end
end
