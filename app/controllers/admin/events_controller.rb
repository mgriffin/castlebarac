# frozen_string_literal: true

module Admin
  class EventsController < ApplicationController
    include Pagy::Backend

    before_action :admin_only!

    def index
      @pagy, @events = pagy(Event.order(start_time: :desc))
    end

    def show
      @event = Event.find(params[:id])
    end

    def new
      @event = Event.new
    end

    def edit
      @event = Event.find(params[:id])
    end

    def create
      @event = Event.new(event_params)

      if @event.save
        redirect_to admin_event_path(@event.id), notice: "Added #{@event.title}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @event = Event.find(params[:id])

      if @event.update(event_params)
        redirect_to admin_event_path(@event.id), notice: "Added #{@event.title}"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def event_params
      params.require(:event).permit(:title, :start_time, :content)
    end
  end
end
