# frozen_string_literal: true

module Admin
  class CompetitionsController < ApplicationController
    before_action :set_competition, only: %i[show edit update destroy]

    def index
      @competitions = Competition.order(date: :desc)
      authorize [:admin, @competitions]
    end

    def show
      authorize [:admin, @competition]
    end

    def new
      @competition = Competition.new
      authorize [:admin, @competition]
    end

    def edit
      authorize [:admin, @competition]
    end

    def create
      @competition = Competition.new(competition_params)
      authorize [:admin, @competition]

      if @competition.save
        redirect_to admin_competition_path(@competition), notice: t(".notice", name: @competition.name)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      authorize [:admin, @competition]

      if @competition.update(competition_params)
        redirect_to admin_competition_path(@competition), notice: t(".notice", name: @competition.name)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize [:admin, @competition]

      if @competition.destroy
        redirect_to admin_competitions_path, notice: t(".notice", name: @competition.name)
      else
        redirect_to admin_competition_path(@competition), alert: @competition.errors.full_messages.to_sentence
      end
    end

    private

    def set_competition
      @competition = Competition.friendly.find(params.expect(:id))
    end

    def competition_params
      params.expect(
        competition: [
          :name, :level, :venue, :date, :entries_close_at, :fee_per_event, :max_events_per_athlete,
          :event_id, :description,
          { competition_events_attributes: [%i[id name distance age_group min_age max_age gender start_time
                                               _destroy]] }
        ]
      )
    end
  end
end
