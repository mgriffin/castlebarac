# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@castlebarac.ie"
  headers "X-PM-Message-Stream": "outbound"
  layout "mailer"
end
