# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :restore_user

  def logged_in?
    Current.user.present?
  end
  helper_method :logged_in?

  def admin?
    Current.user.present? && Current.user.admin?
  end
  helper_method :admin?

  def authenticate_user!
    render plain: "404 Not Found", status: :not_found unless logged_in?
  end

  def admin_only!
    render plain: "404 Not Found", status: :not_found unless admin?
  end

  def restore_user
    return unless (session = find_session_by_cookie)

    session.resume user_agent: request.user_agent, ip_address: request.remote_ip
    Current.user = session.user
    cookies.signed.permanent[:session_token] = { value: session.token, httponly: true, same_site: :lax }
  end

  def find_session_by_cookie
    return unless (token = cookies.signed[:session_token])

    Session.find_by(token:)
  end
end
