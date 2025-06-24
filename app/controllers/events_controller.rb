# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @future_events = Event.order(start_time: :asc).where(start_time: Time.zone.now...).group_by do |event|
      event.start_time.beginning_of_month
    end
    @past_events = Event.order(start_time: :desc).where(start_time: ...Time.zone.now).group_by do |event|
      event.start_time.beginning_of_month
    end
  end

  def show
    @event = Event.find_by(url: params[:id])
  end

  def new
    @event = Event.new
    authorize @event
  end

  def edit
    @event = Event.find_by(url: params[:id])
    authorize @event
  end

  def create
    @event = Event.new(event_params)
    authorize @event

    if @event.save
      redirect_to event_path(@event), notice: "Added #{@event.title}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @event = Event.find_by(url: params[:id])
    authorize @event

    if @event.update(event_params)
      redirect_to event_path(@event), notice: "Updated #{@event.title}"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.expect(event: %i[title start_time content])
  end
end
