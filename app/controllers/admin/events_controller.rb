# frozen_string_literal: true

module Admin
  class EventsController < ApplicationController
    before_action :admin_only!

    def index
      @events = Event.order(start_time: :desc)
    end

    def show
      @event = Event.find_by(url: params[:id])
    end

    def new
      @event = Event.new
    end

    def edit
      @event = Event.find_by(url: params[:id])
    end

    def create
      @event = Event.new(event_params)

      if @event.save
        redirect_to admin_event_path(@event), notice: "Added #{@event.title}"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @event = Event.find_by(url: params[:id])

      if @event.update(event_params)
        redirect_to admin_event_path(@event), notice: "Added #{@event.title}"
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def event_params
      params.expect(event: %i[title start_time content])
    end
  end
end
