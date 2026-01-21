# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    include Pagy::Backend

    before_action :admin_only!, except: :stop_impersonating

    def index
      @pagy, @users = pagy(User.order(created_at: :desc))
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(user_params[:id])

      if @user.update(:admin, user_params[:admin])
        redirect_to admin_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def impersonate
      user = User.find(params[:id])
      impersonate_user(user)
      redirect_to root_path
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to root_path
    end

    private

    def user_params
      params.expect(user: %i[id admin])
    end
  end
end
