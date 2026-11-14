# frozen_string_literal: true

module Training
  class LittleAthleticsController < ApplicationController
    # Public pages
    skip_after_action :verify_authorized

    def index; end
  end
end
