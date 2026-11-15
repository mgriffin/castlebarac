# frozen_string_literal: true

# The addresses collected by the pre-launch sign-up form. Signing up was
# removed along with that form.
class MailingListsController < ApplicationController
  def index
    authorize MailingList
    @entries = MailingList.all
  end
end
