# frozen_string_literal: true

module Admin
  module People
    # Links a person, as a parent, to their child, from the person's edit page
    class RelationshipsController < ApplicationController
      def create
        parent = Person.find_by!(slug: params.expect(:person_id))
        relationship = PersonRelationship.find_or_initialize_by(
          parent:, child_id: params.dig(:person_relationship, :child_id)
        )
        authorize relationship

        if relationship.persisted?
          notice = t(".already_linked", parent: parent.fullname, child: relationship.child.fullname)
        elsif relationship.save
          notice = t(".linked", parent: parent.fullname, child: relationship.child.fullname)
        else
          alert = relationship.errors.full_messages.to_sentence
        end
        redirect_to edit_admin_person_path(parent), notice:, alert:, status: :see_other
      end
    end
  end
end
