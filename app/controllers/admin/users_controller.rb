# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    include Pagy::Backend

    before_action :admin_only!

    def index
      @pagy, @users = pagy(User.order(created_at: :desc))
    end
  end
end
