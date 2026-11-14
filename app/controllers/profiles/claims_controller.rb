# frozen_string_literal: true

module Profiles
  # Lets someone cancel their claim to be an existing person while it's
  # waiting for an admin, e.g. to fill out their details instead
  class ClaimsController < ApplicationController
    # Only uses the signed in user's own claims
    skip_after_action :verify_authorized

    before_action :authenticate_user!

    def destroy
      current_user.person_claims.pending.destroy_all
      redirect_to new_profile_path, notice: t(".cancelled"), status: :see_other
    end
  end
end
