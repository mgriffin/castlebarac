class MailingListsController < ApplicationController
  def create
    email = MailingList.new(mailing_list_params)

    if email.save
      MailingListMailer.with(email: mailing_list_params[:address]).welcome_email.deliver_later
      redirect_to root_url, notice: "You've been added"
    else
      redirect_to root_url, error: "Couldn't add your email address"
    end
  end

  private

  def mailing_list_params
    params.require(:mailing_list).permit(:address)
  end
end
