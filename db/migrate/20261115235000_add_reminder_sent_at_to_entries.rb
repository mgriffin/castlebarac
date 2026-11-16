# frozen_string_literal: true

# Reminders are recorded for each entry, so one that fails to send doesn't
# stop the others, and entries paid for after the first reminders go out
# still get one
class AddReminderSentAtToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :reminder_sent_at, :datetime
  end
end
