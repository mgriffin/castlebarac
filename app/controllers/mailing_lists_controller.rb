# frozen_string_literal: true

class MailingListsController < ApplicationController
  def index
    authorize MailingList
    @entries = MailingList.all
  end

  def create
    authorize MailingList
    email = MailingList.new(mailing_list_params)

    if email.save
      MailingListMailer.with(email: mailing_list_params[:address]).welcome.deliver_later

      redirect_to root_url, notice: t(".notice")
    else
      redirect_to root_url, error: t(".error")
    end
  end

  private

  def mailing_list_params
    params.expect(mailing_list: [:address])
  end
end
