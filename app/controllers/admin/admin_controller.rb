# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    def index
      render plain: "404 Not Found", status: :not_found unless admin?
    end
  end
end
