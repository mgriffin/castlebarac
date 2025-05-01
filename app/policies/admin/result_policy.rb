# frozen_string_literal: true

module Admin
  class ResultPolicy < ApplicationPolicy
    def edit?
      user&.teams&.exists?(name: "Admins")
    end

    def update?
      user&.teams&.exists?(name: "Admins")
    end
  end
end
