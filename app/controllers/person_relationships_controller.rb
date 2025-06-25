# frozen_string_literal: true

class PersonRelationshipsController < ApplicationController
  def create
    if (person_relationship = PersonRelationship.find_by(person_relationship_params))
      redirect_to admin_people_path(person.relationship.parent),
        notice: "already linked"
      return
    end

    person_relationship = PersonRelationship.new(person_relationship_params)

    if person_relationship.save
      redirect_to admin_people_path(person_relationship.parent),
        notice: "Linked"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def person_relationship_params
    params.expect(person_relationship: %i[parent_id child_id])
  end
end
