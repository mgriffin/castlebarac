# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def show?
    user
  end

  # Someone's age and family are only shown to them, their parents and staff
  def private_details?
    return false unless user
    return true if staff?

    user.person.present? && (user.person == record || record.parents.include?(user.person))
  end

  # Finding people by name when filling in forms. It lists children too, so
  # only staff can use it.
  def search?
    staff?
  end

  # Staff can fill in a year of birth or gender we don't have, but only
  # admins can change them once they're set
  def complete_details?
    staff? && !record.entry_details_complete?
  end
end
