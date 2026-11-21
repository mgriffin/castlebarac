# frozen_string_literal: true

# Turns on posting to the site activity room, and reads what would be posted
module SiteActivityHelpers
  include ActiveJob::TestHelper

  WEBHOOK_URL = "https://chat.example.test/webhook/room"

  def enable_site_activity
    SiteActivity.stubs(:webhook_url).returns(WEBHOOK_URL)
  end

  def site_activity_messages
    enqueued_jobs.select { it[:job] == SiteActivityJob }.map { it[:args].first }
  end
end
