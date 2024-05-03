class MailingListMailer < ApplicationMailer
  def welcome_email
    @email = params[:email]
    @url = "https://castlebarac.ie"
    mail(
      to: @email,
      subject: "Thanks for signing up to the mailing list",
      track_opens: "true",
      message_stream: "outbound"
    )
  end
end
