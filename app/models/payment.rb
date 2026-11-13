# frozen_string_literal: true

# Paying for some of the lines in an entry through Stripe Checkout
class Payment < ApplicationRecord
  belongs_to :entry
  has_many :entry_lines, dependent: :nullify

  enum :status, { pending: "pending", paid: "paid", expired: "expired" }, default: "pending"

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }

  # Marks the payment and its lines as paid and sends a confirmation. This can
  # be called more than once for the same payment, e.g. by a webhook and when
  # the user comes back from Stripe.
  def complete!(payment_intent: nil)
    completed = with_lock do
      next false unless pending?

      update!(status: :paid, paid_at: Time.current, stripe_payment_intent_id: payment_intent)
      entry_lines.update_all(paid_at: paid_at) # rubocop:disable Rails/SkipsModelValidations
      true
    end

    CompetitionMailer.with(payment: self).confirmation.deliver_later if completed
    completed
  end

  # The checkout ended without being paid, so its lines can be paid for again
  def mark_expired!
    with_lock do
      next unless pending?

      expired!
      entry_lines.where(paid_at: nil).update_all(payment_id: nil) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  # Stops the checkout from being paid, e.g. because the entry changed
  def expire!
    Stripe::Checkout::Session.expire(stripe_checkout_session_id) if stripe_checkout_session_id
    mark_expired!
  rescue Stripe::InvalidRequestError
    # It's already finished; it only counts as expired if it wasn't paid
    session = Stripe::Checkout::Session.retrieve(stripe_checkout_session_id)
    mark_expired! unless session.status == "complete"
  end
end
