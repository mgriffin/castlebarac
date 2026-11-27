# frozen_string_literal: true

module Competitions
  # Choosing someone to enter, and the events they're entered into
  class AthletesController < ApplicationController
    include CompetitionEntry

    before_action :require_accepting_entries
    before_action -> { authorize @entry, :update? }
    before_action :set_athlete, only: %i[show update destroy]

    # Pick the events they're entered into
    def show
      if @athlete.entry_details_complete?
        set_events
      else
        render :details
      end
    end

    # Pick someone to enter: the user or one of their children, or for staff,
    # anyone
    def new
      @linked_people = linked_people
    end

    # Staff searching for someone to enter
    def create
      return redirect_to new_competition_entry_athlete_path(@competition), alert: t(".choose") if
        params[:person_id].blank?

      athlete = find_athlete(params[:person_id])
      redirect_to competition_entry_athlete_path(@competition, athlete.id)
    end

    def update
      event_ids = ids_param(:competition_event_ids)
      # Staff confirm by entering someone, so they aren't asked
      confirmed_ids = policy(@entry).enter_anyone? ? event_ids : ids_param(:confirmed_event_ids)
      @errors = EntryLines.new(@entry, @athlete).replace(event_ids, confirmed_ids:, confirmer: current_user)

      if @errors.empty?
        redirect_to competition_entry_path(@competition), notice: t(".notice", name: @athlete.firstname)
      else
        set_events(selected_ids: event_ids, confirmed_ids:)
        render :show, status: :unprocessable_content
      end
    end

    def destroy
      EntryLines.new(@entry, @athlete).remove if @entry.persisted?
      redirect_to competition_entry_path(@competition), notice: t(".notice", name: @athlete.firstname)
    end

    private

    def set_events(selected_ids: nil, confirmed_ids: nil)
      @events = @competition.competition_events.select { it.eligible?(@athlete) }
      lines = EntryLine.for_person_in(@athlete, @competition)
      @entered_by_others = lines.where.not(entry: @entry).pluck(:competition_event_id)
      @selected_ids = selected_ids || lines.where(entry: @entry).pluck(:competition_event_id)
      @confirmed_ids = confirmed_ids || lines.where(entry: @entry).where.not(confirmed_at: nil)
                                             .pluck(:competition_event_id)
      @paid_ids = lines.where(entry: @entry).paid.pluck(:competition_event_id)
      @staff_confirms = policy(@entry).enter_anyone?
    end

    def ids_param(name)
      params.fetch(name, []).compact_blank.map(&:to_i)
    end
  end
end
