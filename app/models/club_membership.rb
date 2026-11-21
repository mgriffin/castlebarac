# frozen_string_literal: true

# A person being a member of the club for one year, which runs from January
# to December
class ClubMembership < ApplicationRecord
  belongs_to :person

  # How it's named in the site activity room, e.g. "Joe Bloggs, 2026"
  def site_activity_name = "#{person.fullname}, #{year}"

  validates :year, numericality: { only_integer: true, in: 1900..2999 }
  validates :person_id, uniqueness: { scope: :year }

  # The membership year asked for, e.g. in a URL, or else this year
  def self.year_from(param)
    param.to_i.nonzero? || Date.current.year
  end

  # The years anyone was a member, and this year, newest first
  def self.years
    (distinct.pluck(:year) | [Date.current.year]).sort.reverse
  end
end
