# frozen_string_literal: true

# Posts a message into the site activity room on the Prosody server. If the
# server can't be reached it's tried again for a while, then given up on.
class SiteActivityJob < ApplicationJob
  class Failed < StandardError; end

  retry_on Failed, Timeout::Error, SystemCallError, SocketError, OpenSSL::SSL::SSLError,
           wait: :polynomially_longer, attempts: 5

  def perform(text)
    url = SiteActivity.webhook_url
    return if url.blank?

    uri = URI(url)
    # mod_slack_webhooks only accepts exactly this content type
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { text:, username: "castlebarac.ie" }.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                   open_timeout: 5, read_timeout: 10) { it.request(request) }
    raise Failed, "Prosody said #{response.code}" unless response.is_a?(Net::HTTPSuccess)
  end
end
