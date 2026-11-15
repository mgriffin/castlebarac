# frozen_string_literal: true

module Admin
  class ResultPolicy < ApplicationPolicy
    def edit?
      admin?
    end

    def update?
      admin?
    end
  end
end
