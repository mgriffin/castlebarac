# frozen_string_literal: true

class EntryPolicy < ApplicationPolicy
  def show?
    user.present? && record.user == user
  end

  def update?
    show? && record.accepting_entries?
  end
end
