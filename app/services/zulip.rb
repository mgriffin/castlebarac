# frozen_string_literal: true

class Zulip
  def initialize
    @conn = Faraday.new(
      url: "https://pocleim.zulipchat.com"
    ) do |c|
      c.request :authorization, :basic, Rails.application.credentials.zulip.username,
                Rails.application.credentials.zulip.token
      c.request :url_encoded
    end
  end

  def post(stream:, topic:, message:)
    form_data = {
      type: "stream",
      to: stream,
      topic:,
      content: message
    }

    @conn.post "/api/v1/messages", form_data
  end
end
