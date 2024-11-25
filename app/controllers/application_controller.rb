# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  def admin?
    Current.user.present? && Current.user.admin?
  end
  helper_method :admin?

  def authenticate_user!
    render plain: "404 Not Found", status: :not_found unless authenticated?
  end

  def admin_only!
    render plain: "404 Not Found", status: :not_found unless admin?
  end
end
