# frozen_string_literal: true

class EntryPolicy < ApplicationPolicy
  def show?
    user.present? && record.user == user
  end

  def update?
    show? && record.accepting_entries?
  end

  # Anyone else can only enter themselves and their children
  def enter_anyone?
    staff?
  end
end
