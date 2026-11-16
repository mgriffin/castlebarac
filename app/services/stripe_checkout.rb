# frozen_string_literal: true

# Starts a Stripe Checkout for everything in an entry that hasn't been paid for
class StripeCheckout
  # Stripe won't let a checkout expire any sooner than this
  EXPIRES_IN = 30.minutes

  def initialize(entry, success_url:, cancel_url:)
    @entry = entry
    @success_url = success_url
    @cancel_url = cancel_url
  end

  # Returns the URL to send the user to, or nil if there's nothing to pay for,
  # e.g. because an earlier checkout turned out to have been paid
  def start
    @entry.expire_pending_payments

    lines = @entry.entry_lines.unpaid.includes(:person, :competition_event).to_a
    return if lines.empty?

    # Stripe is called outside the transaction, so other writes aren't held
    # up waiting for it
    payment = claim(lines)
    session = create_session(payment, lines)
    record(payment, session)
    session.url
  end

  private

  # A pending payment for the lines. Raises Payment::InProgress if another
  # checkout took any of them in the meantime, e.g. from a second tab.
  def claim(lines)
    Payment.transaction do
      payment = @entry.payments.create!(amount_cents: lines.size * fee)
      unclaimed = EntryLine.where(id: lines, payment_id: nil)
      claimed = unclaimed.update_all(payment_id: payment.id) # rubocop:disable Rails/SkipsModelValidations
      raise Payment::InProgress if claimed != lines.size

      payment
    end
  end

  def create_session(payment, lines)
    Stripe::Checkout::Session.create(session_params(payment, lines))
  rescue StandardError
    payment.destroy! # its lines can be paid for again
    raise
  end

  # If the session can't be saved, it's stopped so it can't be paid for
  # without us knowing
  def record(payment, session)
    payment.update!(stripe_checkout_session_id: session.id)
  rescue StandardError
    Stripe::Checkout::Session.expire(session.id)
    payment.destroy!
    raise
  end

  def fee
    @entry.competition.fee_per_event_cents
  end

  def session_params(payment, lines)
    {
      mode: "payment",
      customer_email: @entry.user.email,
      client_reference_id: payment.id.to_s,
      metadata: { payment_id: payment.id, competition: @entry.competition.name },
      line_items: lines.map { line_item(it) },
      success_url: @success_url,
      cancel_url: @cancel_url,
      expires_at: EXPIRES_IN.from_now.to_i
    }
  end

  def line_item(line)
    {
      quantity: 1,
      price_data: {
        currency: "eur",
        unit_amount: fee,
        product_data: {
          name: "#{line.person.fullname}: #{line.competition_event.name}",
          description: @entry.competition.name
        }
      }
    }
  end
end
