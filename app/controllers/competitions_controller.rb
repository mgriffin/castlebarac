# frozen_string_literal: true

class CompetitionsController < ApplicationController
  def index
    authorize Competition
    @competitions = Competition.upcoming.published
  end

  def show
    @competition = Competition.friendly.find(params.expect(:id))
    authorize @competition
  end
end
