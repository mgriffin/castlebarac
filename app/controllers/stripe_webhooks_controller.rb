# frozen_string_literal: true

# Stripe tells us here when a checkout has been paid for or has expired
class StripeWebhooksController < ActionController::API
  def create
    event = Stripe::Webhook.construct_event(request.raw_post, request.headers["Stripe-Signature"], secret)
    handle(event.type, event.data.object)
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def handle(type, session)
    payment = Payment.find_by(stripe_checkout_session_id: session.id)
    return if payment.nil?

    case type
    when "checkout.session.completed", "checkout.session.async_payment_succeeded"
      payment.complete!(payment_intent: session.payment_intent) if session.payment_status == "paid"
    when "checkout.session.expired", "checkout.session.async_payment_failed"
      payment.mark_expired!
    end
  end

  def secret
    Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)
  end
end
