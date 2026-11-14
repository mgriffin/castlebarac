# frozen_string_literal: true

# Someone asking for an existing person, e.g. one added from imported
# results, to be linked to their account. Anyone can type a name, so an
# admin approves or rejects each claim.
class PersonClaim < ApplicationRecord
  belongs_to :user
  belongs_to :person
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, default: :pending, validate: true

  validates :user_id, uniqueness: { conditions: -> { pending } }, if: :pending?
  validate :person_has_no_account, on: :create

  # Links the person to the claimant's account. If that can't be done, e.g.
  # someone else has the person now, the claim stays pending and this raises
  # ActiveRecord::RecordInvalid with the reason on the person.
  def approve!(admin)
    transaction do
      AccountLinker.link!(person, user)
      update!(status: :approved, reviewed_by: admin, reviewed_at: Time.current)
    end
  end

  def reject!(admin)
    update!(status: :rejected, reviewed_by: admin, reviewed_at: Time.current)
  end

  private

  def person_has_no_account
    errors.add(:person, :taken) if person&.user_id
  end
end
