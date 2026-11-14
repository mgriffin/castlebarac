# frozen_string_literal: true

module Admin
  class TeamsController < BaseController
    def index
      @teams = Team.all
      authorize [:admin, @teams]
    end

    def show
      @team = Team.find_by!(slug: params.expect(:id))
      authorize [:admin, @team]
      @memberships = @team.memberships.includes(:person)
    end

    def new
      @team = Team.new
      authorize [:admin, @team]
    end

    def create
      @team = Team.new(team_params)
      authorize [:admin, @team]

      if @team.save
        redirect_to admin_teams_path, notice: "Added #{@team.name}"
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def team_params
      params.expect(team: %i[name])
    end
  end
end
