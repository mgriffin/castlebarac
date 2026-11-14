# frozen_string_literal: true

module Admin
  module Teams
    # Adds people to a team and takes them off it, from the team's page
    class MembershipsController < BaseController
      before_action :set_team

      def create
        person = Person.find_by(id: params.dig(:membership, :person_id))
        if person.nil?
          redirect_to admin_team_path(@team), alert: t(".choose"), status: :see_other
          return
        end

        membership = @team.memberships.find_or_create_by!(person:)
        key = membership.previously_new_record? ? ".added" : ".already_a_member"
        redirect_to admin_team_path(@team), notice: t(key, name: person.fullname, team: @team.name), status: :see_other
      end

      def destroy
        membership = @team.memberships.find(params.expect(:id))
        if removing_yourself_from_admins?(membership)
          redirect_to admin_team_path(@team), alert: t(".not_yourself"), status: :see_other
          return
        end

        membership.destroy!
        redirect_to admin_team_path(@team),
                    notice: t(".removed", name: membership.person.fullname, team: @team.name),
                    status: :see_other
      end

      private

      def set_team
        @team = Team.find_by!(slug: params.expect(:team_id))
        authorize [:admin, @team], :update?
      end

      # Stops admins locking themselves out
      def removing_yourself_from_admins?(membership)
        @team.name == "Admins" && membership.person == current_user.person
      end
    end
  end
end
