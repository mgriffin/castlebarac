# frozen_string_literal: true

module Admin
  class MembershipsController < ApplicationController
    def new
      @membership = Membership.new
      @team = Team.find_by(slug: params[:team])
    end

    def create
      membership = Membership.new(membership_params)

      if membership.save
        redirect_to admin_team_path(membership.team),
                    notice: "Added #{membership.person.fullname} to #{membership.team.name}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def membership_params
      params.expect(membership: %i[team_id person_id])
    end
  end
end
