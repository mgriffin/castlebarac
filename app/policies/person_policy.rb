# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def show?
    user
  end

  # Finding people by name when filling in forms. It lists children too, so
  # only staff can use it.
  def search?
    staff?
  end
end
