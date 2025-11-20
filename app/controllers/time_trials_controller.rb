# frozen_string_literal: true

class TimeTrialsController < ApplicationController
  def index
    @time_trials = TimeTrial
                    .select("STRFTIME('%Y-%m-%d', recorded_at) day, id")
                    .group("STRFTIME('%Y-%m-%d', recorded_at)")
    authorize @time_trials
  end

  def show
    @time_trial = TimeTrial.find(params[:id])
    authorize @time_trial
  end

  def new
    @time_trial = TimeTrial.new
    @time_trial.tt_times.build
  end

  def create
    @time_trial = TimeTrial.new(time_trial_params)

    if @time_trial.save!
      redirect_to time_trial_path(@time_trial), notice: "Added Time Trial"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def time_trial_params
    params.expect(
      time_trial: [
        :recorded_at,
        :distance,
        :surface,
        tt_times_attributes: [
          :person_id,
          :seconds
        ]
      ]
    )
  end
end
