# frozen_string_literal: true

# Paying for some of the lines in an entry through Stripe Checkout
class Payment < ApplicationRecord
  # The checkout has been paid but the money hasn't arrived yet, e.g. a bank
  # transfer, so its lines can't be moved to a new checkout
  class InProgress < StandardError; end

  # How long starting a checkout can take, i.e. creating it on Stripe
  STARTING_FOR = 1.minute

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

  # Stops the checkout from being paid, e.g. because the entry changed. If it
  # turns out to have been paid already, it's marked as paid instead, and if
  # the payment is still going through this raises InProgress.
  def expire!
    # The checkout is still being started, unless that failed a while ago
    if stripe_checkout_session_id.nil?
      raise InProgress if created_at > STARTING_FOR.ago

      return mark_expired!
    end

    Stripe::Checkout::Session.expire(stripe_checkout_session_id)
    mark_expired!
  rescue Stripe::InvalidRequestError
    # It's already finished, e.g. paid before the webhook told us
    session = Stripe::Checkout::Session.retrieve(stripe_checkout_session_id)
    if session.status != "complete"
      mark_expired!
    elsif session.payment_status == "paid"
      complete!(payment_intent: session.payment_intent)
    else
      raise InProgress
    end
  end
end
