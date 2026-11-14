# frozen_string_literal: true

module Admin
  # Admin pages that are only for admins, whatever they're about
  class BaseController < ApplicationController
    before_action :authorize_admin

    private

    def authorize_admin
      authorize :admin, :access?
    end
  end
end
