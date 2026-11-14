# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :admin_only!

    def index
      @users = User.includes(:person).order(created_at: :desc)
      @admin_person_ids = Team.find_by(name: "Admins")&.person_ids.to_a
    end

    def show
      @user = User.find(params.expect(:id))
    end

    def impersonate
      user = User.find(params.expect(:id))
      impersonate_user(user)
      redirect_to root_path
    end
  end
end
