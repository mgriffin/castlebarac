# frozen_string_literal: true

module Admin
  module Competitions
    # Opening and closing entries for a competition
    class OpeningsController < BaseController
      def create
        authorize [:admin, @competition], :open_entries?

        if @competition.open_entries
          redirect_to admin_competition_path(@competition), notice: t(".notice")
        else
          redirect_to admin_competition_path(@competition), alert: @competition.errors.full_messages.to_sentence
        end
      end

      def destroy
        authorize [:admin, @competition], :close_entries?

        @competition.close_entries
        redirect_to admin_competition_path(@competition), notice: t(".notice")
      end
    end
  end
end
