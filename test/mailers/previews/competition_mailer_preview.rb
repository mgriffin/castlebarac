# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/competition_mailer
class CompetitionMailerPreview < ActionMailer::Preview
  def confirmation
    CompetitionMailer.with(payment: Payment.paid.last || Payment.new(entry: Entry.last, amount_cents: 1000))
                     .confirmation
  end
end
