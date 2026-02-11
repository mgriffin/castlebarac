# frozen_string_literal: true

module Admin
  class ResultPolicy < ApplicationPolicy
    def edit?
      user.present? && user.teams.exists?(name: "Admins")
    end

    def update?
      user.present? && user.teams.exists?(name: "Admins")
    end
  end
end
