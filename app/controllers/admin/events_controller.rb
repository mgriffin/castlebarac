# frozen_string_literal: true

module Admin
  class EventsController < ApplicationController
    include Pagy::Backend

    before_action :admin_only!

    def new
      @event = Event.new
    end
  end
end
