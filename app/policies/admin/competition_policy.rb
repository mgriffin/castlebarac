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
    def entries? = manage?
    def remove_entry? = manage?

    private

    def manage? = admin_or_committee?
  end
end
