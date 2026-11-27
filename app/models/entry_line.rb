# frozen_string_literal: true

# One person entered into one event
class EntryLine < ApplicationRecord
  belongs_to :entry
  belongs_to :person
  belongs_to :competition_event
  belongs_to :payment, optional: true
  # Who confirmed the athlete has discussed the event with a club coach
  belongs_to :confirmed_by, class_name: "User", optional: true, inverse_of: :confirmed_entry_lines

  validates :competition_event_id, uniqueness: { scope: :person_id }
  validate :event_is_in_competition
  validate :competition_accepting_entries, on: :create
  validate :person_eligible
  validate :within_event_limit, on: :create
  validate :confirmed_if_needed, on: :create

  delegate :competition, to: :entry

  # A line is paid for when its payment is
  scope :paid, -> { where(payment_id: Payment.paid.select(:id)) }
  scope :unpaid, -> { where(payment_id: nil).or(where.not(payment_id: Payment.paid.select(:id))) }

  delegate :paid_at, to: :payment, allow_nil: true

  def paid?
    payment.present? && payment.paid?
  end

  def confirm(user)
    self.confirmed_at = Time.current
    self.confirmed_by = user
  end

  def confirmed?
    confirmed_at.present?
  end

  # Events flagged after someone was entered leave lines that need confirming
  def awaiting_confirmation?
    competition_event.requires_confirmation? && !confirmed?
  end

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

  def confirmed_if_needed
    return if competition_event.nil? || person.nil? || !awaiting_confirmation?

    errors.add(:base, :needs_confirmation, name: person.firstname, event: competition_event.name)
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
