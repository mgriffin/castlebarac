# frozen_string_literal: true

module Admin
  class ResultsController < ApplicationController
    def edit
      @result = Result.find(params[:id])
      authorize [:admin, @result]
    end

    def update
      @result = Result.find(params[:id])
      authorize [:admin, @result]

      unless (person = Person.find(params[:result][:person_id]))
        redirect_to event_path(@result.race.event),
                    notice: "#{params[:result][:person]} wasn't found"
        return
      end

      if @result.update(person: person)
        redirect_to event_path(@result.race.event), notice: "Linked result to #{person.fullname}", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
