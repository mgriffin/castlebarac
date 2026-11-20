# frozen_string_literal: true

# Stripe tells us here when a checkout has been paid for or has expired
class StripeWebhooksController < ActionController::API
  def create
    return missing_secret if secret.blank?

    event = Stripe::Webhook.construct_event(request.raw_post, request.headers["Stripe-Signature"], secret)
    SiteActivity.collect(actor: "Stripe") { handle(event.type, event.data.object) }
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def handle(type, session)
    payment = Payment.find_by(stripe_checkout_session_id: session.id)
    if payment.nil?
      # Nothing we know of, e.g. a checkout that was stopped because it
      # couldn't be saved. If it was paid, it needs refunding by hand.
      return Rails.logger.error("Stripe #{type} for unknown checkout #{session.id} " \
                                "(payment status #{session.payment_status})")
    end

    case type
    when "checkout.session.completed", "checkout.session.async_payment_succeeded"
      payment.complete_if_paid!(session)
    when "checkout.session.expired", "checkout.session.async_payment_failed"
      payment.mark_expired!
    end
  end

  # Stripe keeps retrying, so these go through once the secret is set
  def missing_secret
    Rails.logger.error("Can't check Stripe webhooks: set stripe.webhook_secret in the credentials " \
                       "or STRIPE_WEBHOOK_SECRET")
    head :internal_server_error
  end

  def secret
    Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)
  end
end
