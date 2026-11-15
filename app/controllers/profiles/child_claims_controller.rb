# frozen_string_literal: true

module Profiles
  # Parents asking to be linked to their child, which an admin checks first.
  # They can only ask for someone already on the site, by their full name.
  class ChildClaimsController < ApplicationController
    # Only uses the signed in user's own person and claims
    skip_after_action :verify_authorized

    before_action :authenticate_user!
    before_action :require_profile

    def new; end

    # Asks for the child's name, then which of the people with that name
    def create
      @name = params[:name].to_s.squish
      @matches = @name.present? ? claimable_children : []
      child = @matches.find { it.id.to_s == params[:child_id].to_s }

      if child
        current_user.child_claims.create!(child:)
        redirect_to profile_path, notice: t(".claimed", name: child.fullname)
      else
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      claim = current_user.child_claims.pending.find(params.expect(:id))
      claim.destroy!
      redirect_to profile_path, notice: t(".cancelled", name: claim.child.fullname), status: :see_other
    end

    private

    def require_profile
      redirect_to new_profile_path if current_user.person.nil?
    end

    # People with the name, leaving out the user, their children, and anyone
    # they've already asked for or an admin said wasn't their child
    def claimable_children
      person = current_user.person
      asked = current_user.child_claims.where(status: %i[pending rejected]).pluck(:child_id)
      excluded = [person.id, *person.children.ids, *asked]
      Person.named(@name).reject { excluded.include?(it.id) }
    end
  end
end
