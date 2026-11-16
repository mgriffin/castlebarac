# frozen_string_literal: true

module Admin
  # Admins and committee members look after competitions
  class CompetitionPolicy < ApplicationPolicy
    def index? = manage?
    def show? = manage?
    def create? = manage?
    def update? = manage?
    def destroy? = manage?
    def open_entries? = manage?
    def close_entries? = manage?

    private

    def manage?
      return false unless user

      user.admin? || user.committee?
    end
  end
end
