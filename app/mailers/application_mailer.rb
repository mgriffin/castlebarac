# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  after_action set_postmark_header

  default from: "info@castlebarac.ie"
  layout "mailer"

  private

  def set_postmark_header
    headers["X-PM-Message-Stream"] = "outbound"
  end
end
