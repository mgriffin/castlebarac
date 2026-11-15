# frozen_string_literal: true

# A parent asking to be linked to their child, e.g. to see their results.
# Anyone can type a child's name, so an admin approves or rejects each claim.
class ChildClaim < ApplicationRecord
  belongs_to :user
  belongs_to :child, class_name: "Person"
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, default: :pending, validate: true

  validates :child_id, uniqueness: { scope: :user_id, conditions: -> { pending } }, if: :pending?
  validate :user_has_a_person, :not_themselves, :not_already_their_child, on: :create

  # Links the claimant's person to the child as their parent. If that can't
  # be done, the claim stays pending and this raises
  # ActiveRecord::RecordInvalid with the reason.
  def approve!(admin)
    transaction do
      PersonRelationship.find_or_create_by!(parent: user.person, child:)
      update!(status: :approved, reviewed_by: admin, reviewed_at: Time.current)
    end
  end

  def reject!(admin)
    update!(status: :rejected, reviewed_by: admin, reviewed_at: Time.current)
  end

  private

  def user_has_a_person
    errors.add(:user, :no_person) if user && user.person.nil?
  end

  def not_themselves
    errors.add(:child, :themselves) if child && child == user&.person
  end

  def not_already_their_child
    return if child.nil? || user&.person.nil?

    errors.add(:child, :already_linked) if user.person.children.include?(child)
  end
end
