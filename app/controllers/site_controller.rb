# frozen_string_literal: true

class SiteController < ApplicationController
  include PostsHelper

  allow_unauthenticated_access

  def index
    @mailing_list = MailingList.new
    @posts = Post.order(created_at: :desc).limit(5)
    @events = Event.where(start_time: Time.zone.now..).order(:start_time).limit(5)
  end
end
