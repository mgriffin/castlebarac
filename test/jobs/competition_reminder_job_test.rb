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
    assert_enqueued_email_with CompetitionMailer.with(entry: @paid), :reminder do
      CompetitionReminderJob.perform_now(@three_days_before)
    end

    assert_enqueued_emails 1
    assert_not_nil @competition.reload.reminder_sent_at
  end

  test "only reminds people once" do
    CompetitionReminderJob.perform_now(@three_days_before)

    assert_no_enqueued_emails do
      CompetitionReminderJob.perform_now(@three_days_before + 1)
    end
  end

  test "waits until a few days before" do
    assert_no_enqueued_emails do
      CompetitionReminderJob.perform_now(@competition.date - 4)
    end

    assert_nil @competition.reload.reminder_sent_at
  end

  test "doesn't remind anyone about a draft competition" do
    @competition.entries_draft!

    assert_no_enqueued_emails do
      CompetitionReminderJob.perform_now(@three_days_before)
    end
  end

  test "doesn't remind anyone about a competition that's over" do
    assert_no_enqueued_emails do
      CompetitionReminderJob.perform_now(@competition.date + 1)
    end
  end
end
