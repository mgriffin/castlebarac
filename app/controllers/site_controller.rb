# frozen_string_literal: true

class SiteController < ApplicationController
  include Pagy::Backend

  def index
    @mailing_list = MailingList.new
    @pagy, @posts = pagy(Post.order(created_at: :desc))
    @events = Event.where(start_time: Time.zone.now..).order(:start_time).limit(5)
  end

  def about; end
end
