# frozen_string_literal: true

module Coach
  class PostPolicy < ApplicationPolicy
    def show?
      return false unless user

      user.admin? || user.coach? || user.committee?
    end

    def new?
      return false unless user

      user.admin? || user.coach? || user.committee?
    end

    def create?
      return false unless user

      user.admin? || user.coach? || user.committee?
    end
  end
end
