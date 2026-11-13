# frozen_string_literal: true

class CompetitionsController < ApplicationController
  def index
    @competitions = Competition.upcoming.where.not(status: :draft)
  end

  def show
    @competition = Competition.friendly.find(params.expect(:id))
    raise ActiveRecord::RecordNotFound if @competition.entries_draft? && !policy([:admin, @competition]).show?
  end
end
