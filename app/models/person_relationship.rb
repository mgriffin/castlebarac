# frozen_string_literal: true

class PersonRelationship < ApplicationRecord
  belongs_to :parent,
             class_name: "Person"
  belongs_to :child,
             class_name: "Person"

  # A unique index on [parent_id, child_id] needs a migration that first checks
  # production for existing duplicates
  validates :child_id, uniqueness: { scope: :parent_id } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validate :not_their_own_parent

  private

  def not_their_own_parent
    errors.add(:child, :own_parent) if child_id.present? && child_id == parent_id
  end
end
