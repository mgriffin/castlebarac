# frozen_string_literal: true

class PersonRelationshipPolicy < ApplicationPolicy
  def show?
    staff?
  end

  def create?
    staff?
  end
end
