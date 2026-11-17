# frozen_string_literal: true

module Admin
  module Competitions
    # The pages under one competition. Not Admin::BaseController, which only
    # lets admins in: committee members use some of these pages, so each
    # action authorizes for itself.
    class BaseController < ApplicationController
      before_action :set_competition

      private

      def set_competition
        @competition = Competition.friendly.find(params.expect(:competition_id))
      end
    end
  end
end
