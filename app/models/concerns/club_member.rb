# frozen_string_literal: true

# A person's membership of the club, year by year, and the Athletics Ireland
# registration number that identifies them on the club's member list
module ClubMember
  extend ActiveSupport::Concern

  included do
    has_many :club_memberships, dependent: :destroy

    validates :aai_number, uniqueness: true, allow_nil: true

    normalizes :aai_number, with: -> { it.strip.presence }

    # People who were members of the club in the year
    scope :members_in, ->(year) { where(id: ClubMembership.where(year:).select(:person_id)) }
  end

  # The years they were a member of the club, oldest first
  def member_years
    club_memberships.order(:year).pluck(:year)
  end
end
