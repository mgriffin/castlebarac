# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Every action has to check what the user is allowed to do with Pundit, or
  # say it's public with skip_after_action. Devise's controllers are public.
  after_action :verify_authorized, unless: :devise_controller?

  # Everything changed while handling a request is posted as one message
  around_action :collect_site_activity

  layout "sporty"

  def admin?
    current_user&.admin? || false
  end
  helper_method :admin?

  protected

  def collect_site_activity(&)
    SiteActivity.collect(actor: -> { site_activity_actor }, ip: request.remote_ip, &)
  end

  # Who's doing it, e.g. "mike", or "mike (as jbloggs)" while impersonating
  def site_activity_actor
    return unless current_user
    return current_user.username if true_user == current_user

    "#{true_user.username} (as #{current_user.username})"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
