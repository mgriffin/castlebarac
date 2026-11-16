# frozen_string_literal: true

class CompetitionsController < ApplicationController
  def show
    @competition = Competition.friendly.find(params.expect(:id))
    authorize @competition
  end
end
