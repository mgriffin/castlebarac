# frozen_string_literal: true

require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include StripeHelpers

  setup do
    @entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
    @line = @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    @payment = @entry.payments.create!(amount_cents: 500, stripe_checkout_session_id: "cs_test_123")
    @line.update!(payment: @payment)
  end

  test "completing a payment marks its lines as paid and sends a confirmation" do
    assert_enqueued_email_with CompetitionMailer.with(payment: @payment), :confirmation do
      assert @payment.complete!(payment_intent: "pi_123")
    end

    assert_predicate @payment.reload, :paid?
    assert_equal "pi_123", @payment.stripe_payment_intent_id
    assert_predicate @line.reload, :paid?
    assert_equal 0, @entry.amount_due_cents
    assert_equal 500, @entry.amount_paid_cents
  end

  test "completing a payment twice only confirms it once" do
    @payment.complete!

    assert_no_enqueued_emails do
      assert_not @payment.complete!
    end
  end

  test "an expired payment frees its lines to be paid again" do
    @payment.mark_expired!

    assert_predicate @payment.reload, :expired?
    assert_nil @line.reload.payment
    assert_equal 500, @entry.amount_due_cents
  end

  test "expiring a payment stops the checkout" do
    Stripe::Checkout::Session.expects(:expire).with("cs_test_123").returns(stripe_session(status: "expired"))

    @payment.expire!

    assert_predicate @payment.reload, :expired?
  end

  test "a checkout that was paid before it could be stopped isn't expired" do
    Stripe::Checkout::Session.expects(:expire).raises(Stripe::InvalidRequestError.new("Already complete", nil))
    Stripe::Checkout::Session.expects(:retrieve).returns(stripe_session(status: "complete"))

    @payment.expire!

    assert_predicate @payment.reload, :pending?
  end
end
