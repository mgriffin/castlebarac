# frozen_string_literal: true

class CompetitionMailer < ApplicationMailer
  helper :competitions

  # Sent once an entry has been paid for
  def confirmation
    @payment = params[:payment]
    @entry = @payment.entry
    @competition = @entry.competition
    @lines_by_person = @entry.paid_lines_by_person

    mail(to: @entry.user.email, subject: t(".subject", name: @competition.name))
  end

  # Sent a few days before the competition
  def reminder
    @entry = params[:entry]
    @competition = @entry.competition
    @lines_by_person = @entry.paid_lines_by_person

    mail(to: @entry.user.email,
         subject: t(".subject", name: @competition.name, date: l(@competition.date, format: :long)))
  end
end
