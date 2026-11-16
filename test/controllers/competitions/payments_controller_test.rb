# frozen_string_literal: true

require "test_helper"

module Competitions
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag
    include StripeHelpers

    setup do
      @competition = competitions(:connacht)
      @entry = Entry.create!(competition: @competition, user: users(:bugs))
      @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
      sign_in users(:bugs)
    end

    test "sends you to Stripe to pay" do
      Stripe::Checkout::Session.expects(:create).with do |params|
        params[:success_url] == "#{competition_entry_payment_url(@competition)}?session_id={CHECKOUT_SESSION_ID}"
      end.returns(stripe_session)

      post competition_entry_payment_url(@competition)

      assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_123"
    end

    test "says if the payment couldn't be started" do
      Stripe::Checkout::Session.stubs(:create).raises(Stripe::APIConnectionError.new("Down"))

      post competition_entry_payment_url(@competition)

      assert_redirected_to competition_entry_url(@competition)
      assert_equal "Sorry, we couldn't start the payment. Please try again.", flash[:alert]
    end

    test "says if the last payment is still going through" do
      Stripe::Checkout::Session.stubs(:create).returns(stripe_session(id: "cs_first"))
      post competition_entry_payment_url(@competition)
      Stripe::Checkout::Session.stubs(:expire).raises(Stripe::InvalidRequestError.new("Already complete", nil))
      Stripe::Checkout::Session.stubs(:retrieve).returns(stripe_session(id: "cs_first", status: "complete"))

      post competition_entry_payment_url(@competition)

      assert_redirected_to competition_entry_url(@competition)
      assert_equal "Your last payment is still going through. You can change your entry once it has.", flash[:alert]
      assert_equal 1, @entry.payments.count
    end

    test "can't pay once entries close" do
      @competition.update!(entries_close_at: 1.minute.ago)

      post competition_entry_payment_url(@competition)

      assert_redirected_to competition_entry_url(@competition)
      assert_equal "Entries for this competition are closed", flash[:alert]
    end

    test "marks the entry paid when you come back from Stripe" do
      payment = @entry.payments.create!(amount_cents: 500, stripe_checkout_session_id: "cs_test_123")
      @entry.entry_lines.update_all(payment_id: payment.id) # rubocop:disable Rails/SkipsModelValidations
      Stripe::Checkout::Session.expects(:retrieve).with("cs_test_123")
                               .returns(stripe_session(payment_status: "paid", status: "complete"))

      get competition_entry_payment_url(@competition, session_id: "cs_test_123")

      assert_redirected_to competition_entry_url(@competition)
      assert_match "your entry is paid for", flash[:notice]
      assert_predicate payment.reload, :paid?
    end

    test "can't look at someone else's payment" do
      @entry.payments.create!(amount_cents: 500, stripe_checkout_session_id: "cs_test_123")
      sign_in users(:gabby)

      get competition_entry_payment_url(@competition, session_id: "cs_test_123")

      assert_response :not_found
    end

    test "shows what's left to pay" do
      get competition_entry_url(@competition)

      assert_select "button", "Pay €5.00 and finish"
    end

    test "can't take someone out of an event they've paid for" do
      @entry.entry_lines.update_all(paid_at: Time.current) # rubocop:disable Rails/SkipsModelValidations

      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: { competition_event_ids: [""] }

      assert_response :unprocessable_content
      assert_select ".alert-danger li", /Ciara is already paid for in U12 Girls 600m/
      assert_equal 1, @entry.entry_lines.count
    end
  end
end
