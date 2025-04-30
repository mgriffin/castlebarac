# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    def index?
      user&.teams&.exists?(name: "Admins")
    end

    def update?
      user&.teams&.exists?(name: "Admins")
    end
  end
end
