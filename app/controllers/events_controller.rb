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
end
