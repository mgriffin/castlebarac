# frozen_string_literal: true

class AdminToolbarPolicy < ApplicationPolicy
  def show?
    admin?
  end
end
