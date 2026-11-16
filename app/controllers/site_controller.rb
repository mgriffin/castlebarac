# frozen_string_literal: true

class SiteController < ApplicationController
  # Public pages
  skip_after_action :verify_authorized

  def index
    @posts = Post.order(created_at: :desc).limit(5)
    @events = Event.where(start_time: Time.zone.now..).order(:start_time).limit(5)
    @competitions = if Castlebarac.competition_entries?(current_user)
                      Competition.accepting_entries.order(:entries_close_at)
                    else
                      Competition.none
                    end
  end
end
