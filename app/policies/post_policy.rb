# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false unless user

    user.admin? || user.committee?
  end

  def update?
    return false unless user

    user.admin? || user.committee?
  end
end
