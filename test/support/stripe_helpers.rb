# frozen_string_literal: true

module StripeHelpers
  def stripe_session(id: "cs_test_123", payment_status: "unpaid", status: "open", payment_intent: nil)
    Stripe::Checkout::Session.construct_from(
      id:, url: "https://checkout.stripe.com/c/pay/#{id}", payment_status:, status:, payment_intent:
    )
  end

  def paid_entry_line(entry, person, event)
    entry.entry_lines.create!(person:, competition_event: event, paid_at: Time.current)
  end
end
