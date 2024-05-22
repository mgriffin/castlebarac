# frozen_string_literal: true

class MailingListMailer < ApplicationMailer
  def welcome
    @email = params[:email]
    @url = "https://castlebarac.ie"
    mail(
      to: @email,
      track_opens: "true",
      message_stream: "outbound"
    )
  end
end
