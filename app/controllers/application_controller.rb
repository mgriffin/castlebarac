# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Every action has to check what the user is allowed to do with Pundit, or
  # say it's public with skip_after_action. Devise's controllers are public.
  after_action :verify_authorized, unless: :devise_controller?

  layout "sporty"

  def admin?
    current_user&.admin? || false
  end
  helper_method :admin?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
