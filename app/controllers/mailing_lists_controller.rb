# frozen_string_literal: true

class MailingListsController < ApplicationController
  before_action :authenticate_user!, except: :create

  def index
    @entries = MailingList.all
  end

  def create
    email = MailingList.new(mailing_list_params)

    if email.save
      MailingListMailer.with(email: mailing_list_params[:address]).welcome.deliver_later

      message = "#{mailing_list_params[:address]} has just signed up"
      PostToZulipJob.perform_later(message:, stream: "general", topic: "New Mailing List Member")

      redirect_to root_url, notice: t(".notice")
    else
      redirect_to root_url, error: t(".error")
    end
  end

  private

  def mailing_list_params
    params.require(:mailing_list).permit(:address)
  end
end
