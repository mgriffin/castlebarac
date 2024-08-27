# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  include Pagy::Backend

  before_action :admin_only!

  def index
    @pagy, @users = pagy(User.order(created_at: :desc))
  end
end
