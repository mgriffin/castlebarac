# frozen_string_literal: true

require "test_helper"

class SiteActivityTest < ActiveSupport::TestCase
  include SiteActivityHelpers

  test "nothing is posted without a webhook URL" do
    SiteActivity.note("Hello")
    events(:first).update!(title: "Renamed")

    assert_empty site_activity_messages
  end

  test "outside of a request each change is posted straight away" do
    enable_site_activity

    events(:first).update!(title: "Mayo Championships")
    SiteActivity.note("Hello")

    assert_equal ["✏️ The site edited event “Mayo Championships” (title)", "Hello"], site_activity_messages
  end

  test "everything noted while collecting is posted as one message" do
    enable_site_activity

    SiteActivity.collect(actor: -> { "mike" }) do
      events(:first).update!(title: "Mayo Championships", start_time: Time.zone.local(2026, 12, 1, 10))
      posts(:one).destroy!
      SiteActivity.note("🔑 mike logged in from 1.2.3.4")
    end

    assert_equal [<<~TEXT.chomp], site_activity_messages
      ✏️ mike edited event “Mayo Championships” (title and start time)
      🗑️ mike removed post “This is a title”
      🔑 mike logged in from 1.2.3.4
    TEXT
  end

  test "edits to timestamps and login tracking aren't posted" do
    enable_site_activity

    events(:first).update!(updated_at: 1.minute.from_now)
    users(:bugs).update!(username: "bugs")
    clear_enqueued_jobs
    users(:bugs).update!(sign_in_count: 3, current_sign_in_at: Time.current, current_sign_in_ip: "1.2.3.4")

    assert_empty site_activity_messages
  end

  test "lots of changes are counted instead of listed" do
    enable_site_activity

    SiteActivity.collect(actor: -> { "mike" }) do
      (SiteActivity::LIST_LIMIT + 1).times { Person.create!(firstname: "Runner", surname: it.to_s) }
      events(:first).update!(title: "Mayo Championships")
    end

    assert_equal ["📋 mike made 7 changes: added 6 people and edited 1 event"], site_activity_messages
  end

  test "a new account gets a line of its own" do
    enable_site_activity

    SiteActivity.collect(ip: "1.2.3.4") do
      User.create!(username: "jbloggs", email: "joe@acme.fake", password: "carrots123")
    end

    assert_equal ["🆕 New account: jbloggs (joe@acme.fake) from 1.2.3.4"], site_activity_messages
  end

  test "memberships are named after the person and what they're a member of" do
    enable_site_activity

    ClubMembership.create!(person: people(:ciara), year: 2026)

    assert_equal ["➕ The site added club membership “#{people(:ciara).fullname}, 2026”"], site_activity_messages
  end

  test "a problem noting activity doesn't get in the way" do
    enable_site_activity
    SiteActivityJob.stubs(:perform_later).raises(StandardError, "queue is down")

    assert_nothing_raised { events(:first).update!(title: "Mayo Championships") }
  end
end
