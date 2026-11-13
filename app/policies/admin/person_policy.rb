# frozen_string_literal: true

module Admin
  class PersonPolicy < ApplicationPolicy
    def index?
      admin?
    end

    def show?
      admin?
    end

    def new?
      admin?
    end

    def create?
      admin?
    end

    def update?
      admin?
    end
  end
end
