# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    render plain: "404 Not Found", status: :not_found unless admin?
  end
end
