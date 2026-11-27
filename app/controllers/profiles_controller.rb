# frozen_string_literal: true

# The signed in user's own person. Anyone can type a name, so an existing
# person (with their results, children and teams) is only ever linked to a
# user by an admin. If there are people with the name they give, they can
# claim one for an admin to approve, or make a new person.
class ProfilesController < ApplicationController
  # Every action only uses the signed in user's own person
  skip_after_action :verify_authorized

  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update]
  before_action :redirect_if_profile_exists, only: %i[new create]
  before_action :redirect_if_claim_pending, only: :create

  def show
    @children = @profile.children.includes(results: { race: :event }).order(:firstname)
    @pending_claims = current_user.child_claims.pending.includes(:child)
  end

  def new
    @claim = current_user.person_claims.order(:created_at).last
    @profile = Person.new(Person.split_name(current_user.username.to_s))
  end

  def edit; end

  def create
    @profile = current_user.build_person(profile_params)
    @matches = claimable_people
    choice = params.dig(:profile, :claim).to_s

    if (person = @matches.find { it.id.to_s == choice })
      current_user.person_claims.create!(person:)
      redirect_to new_profile_path, notice: t(".claimed", name: person.fullname)
    elsif (@matches.empty? || choice == "new") && @profile.save
      redirect_to profile_path, notice: t(".thanks")
    else
      # The details need fixing, or they need to say if they're one of @matches
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: t(".thanks")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_profile
    @profile = current_user.person
    redirect_to new_profile_path if @profile.nil?
  end

  def redirect_if_profile_exists
    redirect_to edit_profile_path if current_user.person
  end

  def redirect_if_claim_pending
    redirect_to new_profile_path if current_user.person_claims.pending.exists?
  end

  # People with the name they gave who aren't linked to an account, leaving
  # out any an admin already said weren't them
  def claimable_people
    rejected = current_user.person_claims.rejected.pluck(:person_id)
    Person.named(@profile.fullname).select { it.user_id.nil? && rejected.exclude?(it.id) }
  end

  def profile_params
    params.expect(profile: %i[firstname surname])
  end
end
