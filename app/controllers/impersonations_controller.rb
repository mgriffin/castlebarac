# frozen_string_literal: true

# Stopping impersonating someone. While an admin impersonates someone, the
# current user is that person, so anyone can do this.
class ImpersonationsController < ApplicationController
  skip_after_action :verify_authorized

  def destroy
    SiteActivity.note("🎭 #{true_user.username} stopped acting as #{current_user.username}") if current_user != true_user
    stop_impersonating_user
    redirect_to root_path
  end
end
