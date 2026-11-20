# frozen_string_literal: true

require "test_helper"

class SiteActivityIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include SiteActivityHelpers

  setup do
    enable_site_activity
    users(:bugs).update!(username: "bugs")
    users(:admin).update!(username: "admin")
    clear_enqueued_jobs
  end

  test "logging in is posted with the address" do
    post user_session_path, params: { user: { email: "bugs@acme.fake", password: "carrots" } },
                            env: { "REMOTE_ADDR" => "1.2.3.4" }

    assert_equal ["🔑 bugs logged in from 1.2.3.4"], site_activity_messages
  end

  test "logging in with a remembered login isn't posted" do
    post user_session_path, params: { user: { email: "bugs@acme.fake", password: "carrots", remember_me: "1" } }
    remember_cookie = cookies["remember_user_token"]
    reset!
    clear_enqueued_jobs

    cookies["remember_user_token"] = remember_cookie
    get root_path

    assert_empty site_activity_messages
  end

  test "changes are posted with who made them" do
    sign_in users(:admin)
    get root_path
    clear_enqueued_jobs

    patch admin_event_path(events(:first)), params: { event: { title: "Mayo Championships" } }

    assert_equal ["✏️ admin edited event “Mayo Championships” (title)"], site_activity_messages
  end

  test "changes made while impersonating say who's really making them" do
    users(:bugs).person.teams << teams(:admins)
    sign_in users(:admin)
    post impersonate_admin_user_path(users(:bugs))
    clear_enqueued_jobs

    patch admin_event_path(events(:first)), params: { event: { title: "Mayo Championships" } }

    assert_equal ["✏️ admin (as bugs) edited event “Mayo Championships” (title)"], site_activity_messages
  end

  test "a failed login is posted, but only once in a while for each address" do
    Rails.stubs(:cache).returns(ActiveSupport::Cache::MemoryStore.new)

    2.times do
      post user_session_path, params: { user: { email: "bugs@acme.fake", password: "wrong" } },
                              env: { "REMOTE_ADDR" => "1.2.3.4" }
    end

    assert_equal ["⚠️ Failed login for bugs@acme.fake from 1.2.3.4 " \
                  "(more from there in the next 10 minutes won't be posted)"], site_activity_messages
  end

  test "signing up is posted" do
    post user_registration_path, params: { user: { username: "jbloggs", email: "joe@acme.fake",
                                                   password: "carrots123", password_confirmation: "carrots123" } },
                                 env: { "REMOTE_ADDR" => "1.2.3.4" }

    assert_equal ["🆕 New account: jbloggs (joe@acme.fake) from 1.2.3.4"], site_activity_messages
  end

  test "impersonating someone is posted" do
    sign_in users(:admin)
    get root_path
    clear_enqueued_jobs

    post impersonate_admin_user_path(users(:bugs))
    delete impersonation_path

    assert_equal ["🎭 admin is now acting as bugs", "🎭 admin stopped acting as bugs"], site_activity_messages
  end
end
