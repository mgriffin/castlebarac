# frozen_string_literal: true

# Changes the events a person is entered into as part of an entry
class EntryLines
  def initialize(entry, person)
    @entry = entry
    @person = person
  end

  # Enters the person into exactly these events, returning any errors. Nothing
  # changes if there are errors. Events that need a club coach's OK must be
  # among the confirmed ones, which the confirmer is recorded as confirming.
  def replace(event_ids, confirmed_ids: [], confirmer: nil)
    # First, as an earlier checkout may turn out to have been paid
    @entry.expire_pending_payments

    paid = @entry.entry_lines.paid.where(person: @person).where.not(competition_event_id: event_ids)
    return paid.map { paid_error(it) } if paid.any?

    errors = []

    Entry.transaction do
      @entry.save! if @entry.new_record?
      lines = @entry.entry_lines.where(person: @person)
      lines.where.not(competition_event_id: event_ids).destroy_all

      confirm_existing(lines.includes(:competition_event), confirmed_ids, confirmer)

      (event_ids - lines.pluck(:competition_event_id)).each do |event_id|
        errors.concat(add(event_id, confirmed: confirmed_ids.include?(event_id), confirmer:))
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    errors.uniq
  end

  # Takes the person out of any events that haven't been paid for
  def remove
    @entry.expire_pending_payments
    @entry.entry_lines.unpaid.where(person: @person).destroy_all
  end

  private

  # Returns any errors
  def add(event_id, confirmed:, confirmer:)
    line = @entry.entry_lines.build(person: @person, competition_event_id: event_id)
    line.confirm(confirmer) if confirmed && line.competition_event&.requires_confirmation?
    line.save
    line.errors.full_messages
  end

  # Lines entered before their event needed confirming
  def confirm_existing(lines, confirmed_ids, confirmer)
    lines.select { it.awaiting_confirmation? && confirmed_ids.include?(it.competition_event_id) }.each do |line|
      line.confirm(confirmer)
      line.save!
    end
  end

  def paid_error(line)
    I18n.t("entry_lines.paid", name: @person.firstname, event: line.competition_event.name)
  end
end
