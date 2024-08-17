# frozen_string_literal: true

class SiteController < ApplicationController
  include Pagy::Backend

  def index
    @mailing_list = MailingList.new
    @pagy, @posts = pagy(Post.order(created_at: :desc))
  end

  def about; end
end
