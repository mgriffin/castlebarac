# frozen_string_literal: true

module TimeTrials
  class TtTimesController < ApplicationController
    def new
      @time_trial = TimeTrial.find(params[:time_trial_id])
    end
  end
end
