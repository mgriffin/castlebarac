# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def index
    render plain: "404 Not Found", status: :not_found unless admin?

    @pagy, @users = pagy(User.order(created_at: :desc))
  end
end
