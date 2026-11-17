# frozen_string_literal: true

module StripeHelpers
  def stripe_session(id: "cs_test_123", payment_status: "unpaid", status: "open", payment_intent: nil)
    Stripe::Checkout::Session.construct_from(
      id:, url: "https://checkout.stripe.com/c/pay/#{id}", payment_status:, status:, payment_intent:
    )
  end

  def paid_entry_line(entry, person, event)
    pay_for(entry.entry_lines.create!(person:, competition_event: event)).first
  end

  # Puts the lines in a paid payment, as a finished checkout does
  def pay_for(*lines)
    lines = lines.flatten
    payment = lines.first.entry.payments.create!(amount_cents: 500 * lines.size, status: :paid,
                                                 paid_at: Time.current)
    lines.each { it.update!(payment:) }
  end
end
