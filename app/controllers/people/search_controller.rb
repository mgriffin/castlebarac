# frozen_string_literal: true

module People
  # Suggestions for the autocomplete on staff forms
  class SearchController < ApplicationController
    MIN_LENGTH = 2
    LIMIT = 20

    def index
      authorize Person, :search?

      query = params[:q].to_s.strip
      if query.length < MIN_LENGTH
        @people = Person.none
        @hint = "Type at least #{MIN_LENGTH} letters"
      else
        @people = Person.search(query).order(:surname, :firstname).limit(LIMIT)
      end
      render layout: false
    end
  end
end
