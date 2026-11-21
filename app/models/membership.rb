# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :person
  belongs_to :team

  # How it's named in the site activity room, e.g. "Joe Bloggs in Admins"
  def site_activity_name = "#{person.fullname} in #{team.name}"
end
