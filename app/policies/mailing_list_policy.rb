# frozen_string_literal: true

class MailingListPolicy < ApplicationPolicy
  def index?
    admin?
  end
end
