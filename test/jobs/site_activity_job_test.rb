# frozen_string_literal: true

require "test_helper"

class SiteActivityJobTest < ActiveJob::TestCase
  include SiteActivityHelpers

  test "posts the message to the room's webhook" do
    enable_site_activity
    request = stub_request(:post, WEBHOOK_URL)
              .with(body: { text: "Hello", username: "castlebarac.ie" }.to_json,
                    headers: { "Content-Type" => "application/json" })
              .to_return(status: 201)

    SiteActivityJob.perform_now("Hello")

    assert_requested request
  end

  test "fails so it's tried again when Prosody doesn't take it" do
    enable_site_activity
    stub_request(:post, WEBHOOK_URL).to_return(status: 404)

    assert_raises(SiteActivityJob::Failed) { SiteActivityJob.new.perform("Hello") }
  end

  test "does nothing without a webhook URL" do
    SiteActivityJob.perform_now("Hello")

    assert_not_requested :post, WEBHOOK_URL
  end
end
