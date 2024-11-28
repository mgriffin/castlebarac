# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    include Pagy::Backend

    before_action :admin_only!

    def index
      @pagy, @users = pagy(User.order(created_at: :desc))
    end

    def update
      @user = User.find(user_params[:id])

      if @user.update_attribute(:admin, user_params[:admin])
        respond_to do |format|
          redirect_to admin_users_path
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:id, :admin)
    end
  end
end
