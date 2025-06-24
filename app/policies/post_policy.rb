# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.committee?
  end

  def update?
    user.admin? || user.committee?
  end
end
