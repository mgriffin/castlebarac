# frozen_string_literal: true

class MailingListPolicy < ApplicationPolicy
  def index?
    admin?
  end

  # Anyone can sign up from the home page
  def create?
    true
  end
end
