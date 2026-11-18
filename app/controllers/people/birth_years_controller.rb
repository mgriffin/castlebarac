# frozen_string_literal: true

module People
  # Fills in a person's year of birth and gender if we don't have them, from
  # the lists of people that staff see
  class BirthYearsController < ApplicationController
    def update
      @person = Person.find_by!(slug: params.expect(:person_id))
      authorize @person, :complete_details?

      @person.assign_attributes(details_params)
      if @person.save(context: :entry_details)
        render partial: "people/birth_year", locals: { person: @person }
      else
        # Show the form again for what's still missing, with the errors
        @person.restore_attributes
        render partial: "people/birth_year", locals: { person: @person }, status: :unprocessable_content
      end
    end

    private

    # Only what's missing can be filled in
    def details_params
      missing = []
      missing << :year if @person.birth_year.nil?
      missing << :gender if Competitor::GENDERS.exclude?(@person.gender)
      params.expect(person: missing)
    end
  end
end
