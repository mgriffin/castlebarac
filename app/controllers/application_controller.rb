# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  layout "sporty"

  def admin?
    current_user.present? && current_user.teams.exists?(name: "Admins")
  end
  helper_method :admin?

  def admin_only!
    render plain: "404 Not Found", status: :not_found unless admin?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
