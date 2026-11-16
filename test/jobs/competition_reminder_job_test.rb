# frozen_string_literal: true

require "test_helper"

class CompetitionReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @competition = competitions(:connacht)
    @paid = Entry.create!(competition: @competition, user: users(:bugs))
    @paid.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m),
                              paid_at: Time.current)
    @unpaid = Entry.create!(competition: @competition, user: users(:gabby))
    @unpaid.entry_lines.create!(person: people(:liam), competition_event: competition_events(:u12_boys_600m))
    @three_days_before = @competition.date - 3
  end

  test "reminds people who've paid a few days before" do
    assert_enqueued_with(job: EntryReminderJob, args: [@paid]) do
      CompetitionReminderJob.perform_now(@three_days_before)
    end

    assert_enqueued_jobs 1, only: EntryReminderJob
  end

  test "sends the reminder and records it" do
    assert_emails 1 do
      perform_enqueued_jobs { CompetitionReminderJob.perform_now(@three_days_before) }
    end

    assert_not_nil @paid.reload.reminder_sent_at
    assert_nil @unpaid.reload.reminder_sent_at
  end

  test "only reminds people once" do
    perform_enqueued_jobs { CompetitionReminderJob.perform_now(@three_days_before) }

    assert_no_enqueued_jobs(only: EntryReminderJob) do
      CompetitionReminderJob.perform_now(@three_days_before + 1)
    end
  end

  test "a reminder that failed is tried again" do
    CompetitionMailer.any_instance.stubs(:reminder).raises(Net::SMTPServerBusy).then.returns(nil)

    assert_enqueued_with(job: EntryReminderJob) do
      EntryReminderJob.perform_now(@paid)
    end
    assert_nil @paid.reload.reminder_sent_at
  end

  test "reminds people who pay after the first reminders went out" do
    perform_enqueued_jobs { CompetitionReminderJob.perform_now(@three_days_before) }
    @unpaid.entry_lines.update_all(paid_at: Time.current) # rubocop:disable Rails/SkipsModelValidations

    assert_enqueued_with(job: EntryReminderJob, args: [@unpaid]) do
      CompetitionReminderJob.perform_now(@three_days_before + 1)
    end
  end

  test "waits until a few days before" do
    assert_no_enqueued_jobs(only: EntryReminderJob) do
      CompetitionReminderJob.perform_now(@competition.date - 4)
    end
  end

  test "doesn't remind anyone about a draft competition" do
    @competition.entries_draft!

    assert_no_enqueued_jobs(only: EntryReminderJob) do
      CompetitionReminderJob.perform_now(@three_days_before)
    end
  end

  test "doesn't remind anyone about a competition that's over" do
    assert_no_enqueued_jobs(only: EntryReminderJob) do
      CompetitionReminderJob.perform_now(@competition.date + 1)
    end
  end
end
