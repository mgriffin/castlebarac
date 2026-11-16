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

  # The people the user can enter
  def enterable_people
    return Person.all if enter_anyone?

    person = user&.person
    return Person.none if person.nil?

    Person.where(id: person.id).or(Person.where(id: person.children.select(:id)))
  end
end
