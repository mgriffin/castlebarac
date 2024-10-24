# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :logged_in?

  def show
    @profile = Current.user.profile
  end

  def new
    @profile = Profile.new
  end

  def edit
    @profile = Current.user.profile
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = Current.user

    if @profile.save
      redirect_to profile_path, notice: "Thanks for updating your info"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @profile = Current.user.profile

    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Thanks for updating your info"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:firstname, :surname)
  end
end
