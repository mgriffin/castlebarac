# frozen_string_literal: true

module TimeTrials
  class TtTimesController < ApplicationController
    def new
      @time_trial = TimeTrial.find(params.expect(:time_trial_id))
      authorize @time_trial, :update?
    end
  end
end
