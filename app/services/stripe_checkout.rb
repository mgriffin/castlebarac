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

    Payment.transaction do
      payment = @entry.payments.create!(amount_cents: lines.size * fee)
      session = Stripe::Checkout::Session.create(session_params(payment, lines))
      payment.update!(stripe_checkout_session_id: session.id)
      EntryLine.where(id: lines).update_all(payment_id: payment.id) # rubocop:disable Rails/SkipsModelValidations
      session.url
    end
  end

  private

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
