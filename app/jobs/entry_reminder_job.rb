# frozen_string_literal: true

# Reminds one person about the competition they've entered. Sending is
# retried if it fails, and recorded once it's done.
class EntryReminderJob < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(entry)
    return if entry.reminder_sent_at

    CompetitionMailer.with(entry:).reminder.deliver_now
    entry.update!(reminder_sent_at: Time.current)
  end
end
