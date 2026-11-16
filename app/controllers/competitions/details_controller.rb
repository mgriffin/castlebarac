# frozen_string_literal: true

module Competitions
  # Asks for an athlete's year of birth and gender if we don't have them, as
  # these decide which events they can enter
  class DetailsController < ApplicationController
    include CompetitionEntry

    before_action :require_accepting_entries
    before_action -> { authorize @entry, :update? }
    before_action :set_athlete

    def update
      return redirect_to competition_entry_athlete_path(@competition, @athlete.id) if @athlete.entry_details_complete?

      @athlete.assign_attributes(params.expect(person: %i[year gender]))

      if @athlete.save(context: :entry_details)
        redirect_to competition_entry_athlete_path(@competition, @athlete.id)
      else
        render "competitions/athletes/details", status: :unprocessable_content
      end
    end
  end
end
