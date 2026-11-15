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

    # Pick someone to enter: the user or one of their children
    def new
      @linked_people = linked_people
    end

    def update
      event_ids = params.fetch(:competition_event_ids, []).compact_blank.map(&:to_i)
      @errors = EntryLines.new(@entry, @athlete).replace(event_ids)

      if @errors.empty?
        redirect_to competition_entry_path(@competition), notice: t(".notice", name: @athlete.firstname)
      else
        set_events(selected_ids: event_ids)
        render :show, status: :unprocessable_content
      end
    end

    def destroy
      EntryLines.new(@entry, @athlete).remove if @entry.persisted?
      redirect_to competition_entry_path(@competition), notice: t(".notice", name: @athlete.firstname)
    end

    private

    def set_events(selected_ids: nil)
      @events = @competition.competition_events.select { it.eligible?(@athlete) }
      lines = EntryLine.for_person_in(@athlete, @competition)
      @entered_by_others = lines.where.not(entry: @entry).pluck(:competition_event_id)
      @selected_ids = selected_ids || lines.where(entry: @entry).pluck(:competition_event_id)
      @paid_ids = lines.where(entry: @entry).paid.pluck(:competition_event_id)
    end
  end
end
