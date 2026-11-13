# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    def index?
      admin?
    end

    def update?
      admin?
    end
  end
end
