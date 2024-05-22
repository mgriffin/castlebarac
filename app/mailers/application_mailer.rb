# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@castlebarac.ie"
  layout "mailer"
end
