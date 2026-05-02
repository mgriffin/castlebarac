# frozen_string_literal: true

class CoachPolicy < ApplicationPolicy
  def index?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end
end
