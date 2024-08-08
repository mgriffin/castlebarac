# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

  def create
    if user = User.authenticate_by(user_params)
      user.sessions.start!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        cookies.signed.permanent[:session_token] = { value: session.token, httponly: true, same_site: :lax }
      end
    else
      flash[:alert] = "Wrong email or password"
      render :new, status: :unauthorized
    end
  end

  def destroy
    cookies.delete(:session_token)

    redirect_to root_url
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
