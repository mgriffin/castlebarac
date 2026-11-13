# frozen_string_literal: true

# Everything one user has entered into a competition
class Entry < ApplicationRecord
  belongs_to :competition
  belongs_to :user
  has_many :entry_lines, -> { includes(:competition_event).order(:id) },
           dependent: :destroy,
           inverse_of: :entry
  has_many :people, -> { distinct }, through: :entry_lines
  has_many :payments, dependent: :restrict_with_error

  validates :user_id, uniqueness: { scope: :competition_id }

  delegate :accepting_entries?, to: :competition

  # { person => [entry lines] }
  def lines_by_person
    entry_lines.includes(:person).group_by(&:person)
  end

  # What's still to be paid. An entry isn't finished until it's paid for.
  def amount_due_cents
    entry_lines.unpaid.count * competition.fee_per_event_cents
  end

  def amount_paid_cents
    payments.paid.sum(:amount_cents)
  end

  # Stops any checkout that's under way, as what it charges for is changing
  def expire_pending_payments
    payments.pending.find_each(&:expire!)
  end
end
