# frozen_string_literal: true

module Competitions
  # The people a user has entered into a competition
  class EntriesController < ApplicationController
    include CompetitionEntry

    def show
      authorize @entry
    end
  end
end
