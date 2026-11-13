# frozen_string_literal: true

# Reminds everyone who's entered a competition a few days beforehand
class CompetitionReminderJob < ApplicationJob
  DAYS_BEFORE = 3

  def perform(today = Date.current)
    Competition.where(date: today..(today + DAYS_BEFORE), reminder_sent_at: nil)
               .where.not(status: :draft)
               .find_each { remind(it) }
  end

  private

  def remind(competition)
    # Claim the competition first so reminders can only go out once
    claimed = Competition.where(id: competition.id, reminder_sent_at: nil)
                         .update_all(reminder_sent_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    return unless claimed == 1

    competition.entries.joins(:entry_lines).merge(EntryLine.paid).distinct.find_each do |entry|
      CompetitionMailer.with(entry:).reminder.deliver_later
    end
  end
end
