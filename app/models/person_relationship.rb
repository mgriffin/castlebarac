# frozen_string_literal: true

class PersonRelationship < ApplicationRecord
  belongs_to :parent,
             class_name: "Person",
             inverse_of: :child_parent_relationships
  belongs_to :child,
             class_name: "Person",
             inverse_of: :parent_child_relationships

  validates :child_id, uniqueness: { scope: :parent_id }
  validate :not_their_own_parent

  private

  def not_their_own_parent
    errors.add(:child, :own_parent) if child_id.present? && child_id == parent_id
  end
end
