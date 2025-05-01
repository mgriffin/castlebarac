# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def show?
    user
  end
end
