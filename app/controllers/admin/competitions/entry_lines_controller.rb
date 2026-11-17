# frozen_string_literal: true

module Admin
  module Competitions
    # Takes someone out of an event. Refunds are done by hand in Stripe.
    class EntryLinesController < BaseController
      def destroy
        authorize [:admin, @competition], :remove_entry?

        line = @competition.entry_lines.find(params.expect(:id))
        line.destroy!
        redirect_to admin_competition_entries_path(@competition),
                    notice: t(".notice", name: line.person.fullname, event: line.competition_event.name)
      end
    end
  end
end
