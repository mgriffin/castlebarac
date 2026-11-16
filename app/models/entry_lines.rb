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

  # Takes the person out of the competition
  def remove
    @entry.entry_lines.where(person: @person).destroy_all
  end
end
