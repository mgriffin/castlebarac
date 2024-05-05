class SiteController < ApplicationController
  def index
    @mailing_list = MailingList.new
  end

  def about
  end
end
