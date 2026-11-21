# frozen_string_literal: true

# Posts a message into the site activity room on the Prosody server. If the
# server can't be reached it's tried again for a while, then given up on.
class SiteActivityJob < ApplicationJob
  class Failed < StandardError; end

  retry_on Failed, wait: :polynomially_longer, attempts: 5

  def perform(text)
    url = SiteActivity.webhook_url
    return if url.blank?

    # mod_slack_webhooks only accepts exactly this content type
    response = Typhoeus.post(url, body: { text:, username: "castlebarac.ie" }.to_json,
                                  headers: { "Content-Type" => "application/json" },
                                  connecttimeout: 5, timeout: 10)
    raise Failed, "Prosody said #{response.code} #{response.return_message}" unless response.success?
  end
end
