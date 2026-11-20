# frozen_string_literal: true

module Admin
  # The club's members in a year. Not Admin::BaseController, which only lets
  # admins in: committee members keep the member list too.
  class MembersController < ApplicationController
    # GET /admin/members?year=2026
    def index
      authorize [:admin, ClubMembership]

      @years = ClubMembership.years
      @year = ClubMembership.year_from(params[:year])
      @people = Person.members_in(@year).order(:surname, :firstname).to_a
    end
  end
end
