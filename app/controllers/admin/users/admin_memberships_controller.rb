# frozen_string_literal: true

module Admin
  module Users
    # Adds a user to, or removes them from, the Admins team. Teams are made
    # of people, so the user needs to be linked to a person.
    class AdminMembershipsController < BaseController
      before_action :load_user

      def create
        if @user.person.nil?
          redirect_to admin_users_path, alert: t(".no_person", email: @user.email), status: :see_other
          return
        end

        Membership.find_or_create_by!(person: @user.person, team: admins)
        redirect_to admin_users_path, notice: t(".added", name: @user.name), status: :see_other
      end

      def destroy
        if @user == current_user
          redirect_to admin_users_path, alert: t(".not_yourself"), status: :see_other
          return
        end

        Membership.where(person: @user.person, team: admins).destroy_all if @user.person
        redirect_to admin_users_path, notice: t(".removed", name: @user.name || @user.email), status: :see_other
      end

      private

      def load_user
        @user = User.find(params.expect(:user_id))
      end

      def admins
        Team.find_or_create_by!(name: "Admins")
      end
    end
  end
end
