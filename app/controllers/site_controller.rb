# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    @mailing_list = MailingList.new
    @posts = Post.all
  end

  def about; end
end
