# frozen_string_literal: true

# The signed in user's own person. Creating a profile always makes a new
# person: anyone can type a name, so an existing person (with their results,
# children and teams) is only ever linked to a user by an admin.
class ProfilesController < ApplicationController
  # Every action only uses the signed in user's own person
  skip_after_action :verify_authorized

  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update]
  before_action :redirect_if_profile_exists, only: %i[new create]

  def show; end

  def new
    @profile = Person.new(Person.split_name(current_user.username.to_s))
  end

  def edit; end

  def create
    @profile = current_user.build_person(profile_params)

    if @profile.save
      redirect_to profile_path, notice: t(".thanks")
    else
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

  def profile_params
    params.expect(profile: %i[firstname surname])
  end
end
