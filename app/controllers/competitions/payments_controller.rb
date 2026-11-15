# frozen_string_literal: true

module Competitions
  # Paying for an entry, which finishes it
  class PaymentsController < ApplicationController
    include CompetitionEntry

    # Where Stripe sends people back to once they've paid. The webhook usually
    # gets there first, but this means they see that it's paid straight away.
    def show
      authorize @entry
      payment = @entry.payments.find_by!(stripe_checkout_session_id: params.expect(:session_id))
      session = Stripe::Checkout::Session.retrieve(payment.stripe_checkout_session_id)
      payment.complete!(payment_intent: session.payment_intent) if session.payment_status == "paid"

      if payment.reload.paid?
        redirect_to competition_entry_path(@competition), notice: t(".paid")
      else
        redirect_to competition_entry_path(@competition), notice: t(".waiting")
      end
    end

    def create
      authorize @entry, :show?
      return redirect_to competition_entry_path(@competition), alert: t("competitions.entries_closed") unless
        @competition.accepting_entries?

      authorize @entry, :update?
      return redirect_to competition_entry_path(@competition) if @entry.new_record? || @entry.amount_due_cents.zero?

      url = checkout_url
      return redirect_to competition_entry_path(@competition), notice: t(".paid") if url.nil?

      redirect_to url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      Rails.logger.error("Couldn't start a Stripe checkout: #{e.message}")
      redirect_to competition_entry_path(@competition), alert: t(".failed")
    end

    private

    def checkout_url
      StripeCheckout.new(
        @entry,
        # Stripe fills in the session ID, so the braces can't be escaped
        success_url: "#{competition_entry_payment_url(@competition)}?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: competition_entry_url(@competition)
      ).start
    end
  end
end
