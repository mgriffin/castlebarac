class UsersController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_user, only: :update

  def index
    @unapproved_pagy, @unapproved_users = pagy(User.unapproved)
    @approved_pagy, @approved_users = pagy(User.approved)
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "User updated"
      redirect_back(fallback_location: users_path)
    else
      flash[:error] = "Something went wrong"
      redirect_back(fallback_location: users_path)
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:approved)
  end
end
