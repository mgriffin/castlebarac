# frozen_string_literal: true

module Admin
  module Competitions
    # Opening and closing entries for a competition
    class OpeningsController < ApplicationController
      before_action :set_competition

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

      private

      def set_competition
        @competition = Competition.friendly.find(params.expect(:competition_id))
      end
    end
  end
end
