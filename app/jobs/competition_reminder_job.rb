# frozen_string_literal: true

# Reminds everyone who's paid for an entry into a competition a few days
# beforehand. It runs every day, so anyone who pays after the first
# reminders go out, or whose reminder didn't go, is reminded the next day.
class CompetitionReminderJob < ApplicationJob
  DAYS_BEFORE = 3

  def perform(today = Date.current)
    Entry.joins(:competition)
         .where(reminder_sent_at: nil, competitions: { date: today..(today + DAYS_BEFORE) })
         .merge(Competition.published)
         .where(id: EntryLine.paid.select(:entry_id))
         .find_each { EntryReminderJob.perform_later(it) }
  end
end
