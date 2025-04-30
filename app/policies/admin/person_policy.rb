# frozen_string_literal: true

module Admin
  class PersonPolicy < ApplicationPolicy
    def index?
      user&.teams&.exists?(name: "Admins")
    end

    def show?
      user&.teams&.exists?(name: "Admins")
    end

    def new?
      user&.teams&.exists?(name: "Admins")
    end

    def create?
      user&.teams&.exists?(name: "Admins")
    end

    def update?
      user&.teams&.exists?(name: "Admins")
    end
  end
end

