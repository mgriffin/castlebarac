# frozen_string_literal: true

# Changes the events a person is entered into as part of an entry
class EntryLines
  def initialize(entry, person)
    @entry = entry
    @person = person
  end

  # Enters the person into exactly these events, returning any errors. Nothing
  # changes if there are errors.
  def replace(event_ids)
    # First, as an earlier checkout may turn out to have been paid
    @entry.expire_pending_payments

    paid = @entry.entry_lines.paid.where(person: @person).where.not(competition_event_id: event_ids)
    return paid.map { paid_error(it) } if paid.any?

    errors = []

    Entry.transaction do
      @entry.save! if @entry.new_record?
      lines = @entry.entry_lines.where(person: @person)
      lines.where.not(competition_event_id: event_ids).destroy_all

      (event_ids - lines.pluck(:competition_event_id)).each do |event_id|
        line = @entry.entry_lines.create(person: @person, competition_event_id: event_id)
        errors.concat(line.errors.full_messages)
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

  def paid_error(line)
    I18n.t("entry_lines.paid", name: @person.firstname, event: line.competition_event.name)
  end
end
