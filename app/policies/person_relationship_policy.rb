# frozen_string_literal: true

# Who can see someone's family is up to PersonPolicy#private_details?
class PersonRelationshipPolicy < ApplicationPolicy
  def create?
    staff?
  end
end
