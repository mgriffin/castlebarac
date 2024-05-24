class UsersController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def index
    @unapproved_pagy, @unapproved_users = pagy(User.unapproved)
    @approved_pagy, @approved_users = pagy(User.approved)
  end
end
