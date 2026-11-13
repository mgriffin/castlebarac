# frozen_string_literal: true

class CompetitionMailer < ApplicationMailer
  helper :competitions

  # Sent once an entry has been paid for
  def confirmation
    @payment = params[:payment]
    @entry = @payment.entry
    @competition = @entry.competition
    @lines_by_person = @entry.entry_lines.paid.includes(:person).group_by(&:person)

    mail(to: @entry.user.email, subject: t(".subject", name: @competition.name))
  end
end
