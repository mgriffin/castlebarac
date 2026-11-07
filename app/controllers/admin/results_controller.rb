# frozen_string_literal: true

module Admin
  class ResultsController < ApplicationController
    def edit
      @result = Result.find(params.expect(:id))
      authorize [:admin, @result]
    end

    def update
      @result = Result.find(params.expect(:id))
      authorize [:admin, @result]

      link = params.expect(result: %i[person person_id])
      unless (person = Person.find_by(id: link[:person_id]))
        redirect_to event_path(@result.race.event),
                    notice: "#{link[:person]} wasn't found", status: :see_other
        return
      end

      if @result.update(person: person)
        redirect_to event_path(@result.race.event), notice: "Linked result to #{person.fullname}", status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end
  end
end
