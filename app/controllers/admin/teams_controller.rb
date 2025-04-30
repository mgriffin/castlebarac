# frozen_string_literal: true

module Admin
  class TeamsController < ApplicationController
    def index
      @teams = Team.all
    end

    def show
      @team = Team.find_by(slug: params[:id])
    end

    def new
      @team = Team.new
    end

    def create
      @team = Team.new(team_params)

      if @team.save
        redirect_to admin_teams_path, notice: "Added #{@team.name}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def team_params
      params.expect(team: %i[name])
    end
  end
end
