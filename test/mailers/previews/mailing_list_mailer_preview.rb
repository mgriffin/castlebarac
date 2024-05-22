# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/mailing_list_mailer
class MailingListMailerPreview < ActionMailer::Preview
  def welcome_email
    MailingListMailer.with(email: User.first.email).welcome_email
  end
end
