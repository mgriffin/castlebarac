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

  validates :child_id, uniqueness: { scope: :parent_id }
  validate :not_their_own_parent

  private

  def not_their_own_parent
    errors.add(:child, :own_parent) if child_id.present? && child_id == parent_id
  end
end
