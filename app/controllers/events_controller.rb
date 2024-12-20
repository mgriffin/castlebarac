# frozen_string_literal: true

class EventsController < ApplicationController
  allow_unauthenticated_access

  def index
    @future_events = Event.order(start_time: :asc).where(start_time: Time.now...).group_by { |p| p.start_time.beginning_of_month }
    @past_events = Event.order(start_time: :desc).where(start_time: ...Time.now).group_by { |p| p.start_time.beginning_of_month }
  end

  def show
    @event = Event.find(params[:id])
  end
end
