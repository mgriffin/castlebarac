# frozen_string_literal: true

# A person being a member of the club for one year, which runs from January
# to December
class ClubMembership < ApplicationRecord
  belongs_to :person

  validates :year, numericality: { only_integer: true, in: 1900..2999 }
  validates :person_id, uniqueness: { scope: :year }

  # The years anyone was a member, and this year, newest first
  def self.years
    (distinct.pluck(:year) | [Date.current.year]).sort.reverse
  end
end
