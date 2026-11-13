# frozen_string_literal: true

class PersonRelationship < ApplicationRecord
  belongs_to :parent,
             class_name: "Person"
  belongs_to :child,
             class_name: "Person"

  # Links a parent and child, e.g. when a parent enters their child into a
  # competition. Links made this way are marked as self declared so admins
  # can tell them apart.
  def self.declare(parent:, child:)
    find_or_create_by!(parent:, child:) { it.self_declared = true }
  end
end
