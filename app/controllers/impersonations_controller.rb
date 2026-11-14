# frozen_string_literal: true

# Stopping impersonating someone. While an admin impersonates someone, the
# current user is that person, so anyone can do this.
class ImpersonationsController < ApplicationController
  def destroy
    stop_impersonating_user
    redirect_to root_path
  end
end
