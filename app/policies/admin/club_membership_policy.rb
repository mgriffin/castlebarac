# frozen_string_literal: true

module Admin
  # Admins and committee members keep the list of club members
  class ClubMembershipPolicy < ApplicationPolicy
    def index? = admin_or_committee?
    def create? = admin_or_committee?
  end
end
