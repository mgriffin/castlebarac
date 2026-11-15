# frozen_string_literal: true

require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  SECRET = "whsec_test"

  setup do
    entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
    @line = entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    @payment = entry.payments.create!(amount_cents: 500, stripe_checkout_session_id: "cs_test_123")
    @line.update!(payment: @payment)
    ENV["STRIPE_WEBHOOK_SECRET"] = SECRET
  end

  teardown { ENV.delete("STRIPE_WEBHOOK_SECRET") }

  test "marks a payment as paid" do
    send_event("checkout.session.completed", payment_status: "paid")

    assert_response :ok
    assert_predicate @payment.reload, :paid?
    assert_predicate @line.reload, :paid?
  end

  test "waits for delayed payments to go through" do
    send_event("checkout.session.completed", payment_status: "unpaid")

    assert_predicate @payment.reload, :pending?
  end

  test "marks a payment as expired" do
    send_event("checkout.session.expired", payment_status: "unpaid")

    assert_predicate @payment.reload, :expired?
  end

  test "logs events for checkouts it doesn't know" do
    @payment.update!(stripe_checkout_session_id: "cs_other")
    Rails.logger.expects(:error).with(regexp_matches(/unknown checkout cs_test_123 \(payment status paid\)/))

    send_event("checkout.session.completed", payment_status: "paid")

    assert_response :ok
  end

  test "ignores events without a valid signature" do
    post stripe_webhooks_url, params: event_json("checkout.session.completed", payment_status: "paid"),
                              headers: { "Stripe-Signature" => "t=1,v1=nope", "Content-Type" => "application/json" }

    assert_response :bad_request
    assert_predicate @payment.reload, :pending?
  end

  private

  def event_json(type, payment_status:)
    { id: "evt_123", object: "event", type:,
      data: { object: { id: "cs_test_123", object: "checkout.session", payment_status:, payment_intent: "pi_123" } } }
      .to_json
  end

  def send_event(type, payment_status:)
    payload = event_json(type, payment_status:)
    timestamp = Time.now.to_i
    signature = Stripe::Webhook::Signature.compute_signature(Time.zone.at(timestamp), payload, SECRET)
    header = Stripe::Webhook::Signature.generate_header(Time.zone.at(timestamp), signature)

    post stripe_webhooks_url, params: payload, headers: { "Stripe-Signature" => header,
                                                          "Content-Type" => "application/json" }
  end
end
