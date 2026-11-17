# frozen_string_literal: true

require "test_helper"

class StripeCheckoutTest < ActiveSupport::TestCase
  include StripeHelpers

  setup do
    @entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
    @entry.entry_lines.create!(person: people(:liam), competition_event: competition_events(:u12_boys_600m))
    @checkout = StripeCheckout.new(@entry, success_url: "https://example.com/paid", cancel_url: "https://example.com")
  end

  test "charges for each athlete in each event that isn't paid for" do
    paid_entry_line(@entry, people(:ciara), competition_events(:u12_girls_long_jump))

    Stripe::Checkout::Session.expects(:create).with do |params|
      params[:line_items].map { it.dig(:price_data, :product_data, :name) } ==
        ["Ciara Walsh: U12 Girls 600m", "Liam Walsh: U12 Boys 600m"] &&
        params[:line_items].all? { it.dig(:price_data, :unit_amount) == 500 } &&
        params[:customer_email] == "bugs@acme.fake"
    end.returns(stripe_session)

    assert_equal "https://checkout.stripe.com/c/pay/cs_test_123", @checkout.start

    payment = @entry.payments.pending.sole

    assert_equal 1000, payment.amount_cents
    assert_equal "cs_test_123", payment.stripe_checkout_session_id
    assert_equal 2, payment.entry_lines.count
  end

  test "stops any earlier checkout" do
    Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_first"))
    @checkout.start

    Stripe::Checkout::Session.expects(:expire).with("cs_first")
    Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_second"))
    @checkout.start

    assert_equal %w[expired pending], @entry.payments.order(:id).pluck(:status)
    assert_equal [@entry.payments.last.id], @entry.entry_lines.pluck(:payment_id).uniq
  end

  test "doesn't keep the payment if Stripe fails" do
    Stripe::Checkout::Session.stubs(:create).raises(Stripe::APIConnectionError.new("Down"))

    assert_raises(Stripe::APIConnectionError) { @checkout.start }
    assert_empty @entry.payments.reload
  end

  test "doesn't charge again for a checkout that was paid before it could be stopped" do
    Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_first"))
    @checkout.start

    Stripe::Checkout::Session.expects(:expire).raises(Stripe::InvalidRequestError.new("Already complete", nil))
    paid = stripe_session(id: "cs_first", status: "complete", payment_status: "paid")
    Stripe::Checkout::Session.expects(:retrieve).returns(paid)
    Stripe::Checkout::Session.expects(:create).never

    assert_nil @checkout.start
    assert_equal %w[paid], @entry.payments.pluck(:status)
    assert_equal 0, @entry.amount_due_cents
  end

  test "doesn't start another checkout while a payment is going through" do
    Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_first"))
    @checkout.start
    first = @entry.payments.sole

    Stripe::Checkout::Session.expects(:expire).raises(Stripe::InvalidRequestError.new("Already complete", nil))
    Stripe::Checkout::Session.expects(:retrieve).returns(stripe_session(id: "cs_first", status: "complete"))

    assert_raises(Payment::InProgress) { @checkout.start }
    assert_equal [first.id], @entry.entry_lines.pluck(:payment_id).uniq
  end

  test "doesn't hold up the database while Stripe is called" do
    # Each test runs in a transaction of its own
    outside = ActiveRecord::Base.connection.open_transactions
    Stripe::Checkout::Session.expects(:create).with do
      assert_equal outside, ActiveRecord::Base.connection.open_transactions, "Stripe was called inside a transaction"
      true
    end.returns(stripe_session)

    @checkout.start
  end

  test "stops the checkout if it can't be saved" do
    Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_lost"))
    Payment.any_instance.stubs(:update!).raises(ActiveRecord::RecordInvalid)
    Stripe::Checkout::Session.expects(:expire).with("cs_lost")

    assert_raises(ActiveRecord::RecordInvalid) { @checkout.start }
    assert_empty @entry.payments.reload
    assert_equal [nil], @entry.entry_lines.pluck(:payment_id).uniq
  end

  test "won't take lines another checkout has taken in the meantime" do
    other = @entry.payments.create!(amount_cents: 500, stripe_checkout_session_id: "cs_other")
    Entry.any_instance.stubs(:expire_pending_payments)
    @entry.entry_lines.first.update!(payment: other)
    Stripe::Checkout::Session.expects(:create).never

    assert_raises(Payment::InProgress) { @checkout.start }
    assert_equal [other], @entry.payments.reload.to_a
  end
end
