# frozen_string_literal: true

class TimeTrialPolicy < ApplicationPolicy
  def index?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end

  def show?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end

  def create?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end

  def update?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end
end
