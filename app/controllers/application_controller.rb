# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  layout :which_layout

  def admin?
    current_user.present? && current_user.teams.exists?(name: "Admins")
  end
  helper_method :admin?

  def admin_only!
    render plain: "404 Not Found", status: :not_found unless admin?
  end

  private

  def which_layout
    Flipper.enabled?(:sporty, current_user) ? "sporty" : "application"
  end
end
