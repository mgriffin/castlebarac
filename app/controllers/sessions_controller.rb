# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    if (user = User.authenticate_by(user_params))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      @user = User.new
      render "sessions/new", status: :unauthorized
    end
  end

  def destroy
    terminate_session
    redirect_to root_url
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
