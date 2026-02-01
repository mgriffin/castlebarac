# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc).limit(5)
    @events = Event.where(start_time: Time.zone.now..).order(:start_time).limit(5)
  end
end
