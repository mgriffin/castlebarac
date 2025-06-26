# frozen_string_literal: true

class PersonRelationshipPolicy < ApplicationPolicy
  def show?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end

  def create?
    return false unless user

    user.admin? || user.coach? || user.committee?
  end
end
