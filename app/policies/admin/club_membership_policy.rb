# frozen_string_literal: true

module Admin
  # Admins and committee members keep the list of club members
  class ClubMembershipPolicy < ApplicationPolicy
    def index? = manage?
    def create? = manage?

    private

    def manage?
      return false unless user

      user.admin? || user.committee?
    end
  end
end
