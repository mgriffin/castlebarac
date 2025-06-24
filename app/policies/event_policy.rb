# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.coach? || user.committee?
  end

  def update?
    user.admin? || user.coach? || user.committee?
  end
end
