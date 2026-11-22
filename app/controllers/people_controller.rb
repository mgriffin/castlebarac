# frozen_string_literal: true

class PeopleController < ApplicationController
  def show
    @person = Person.find_by!(slug: params.expect(:id))
    authorize @person

    @results_by_distance = @person.results_by_distance
    @private_details = policy(@person).private_details?
    # Someone without results, e.g. a parent, has their children instead
    @children = @person.children.includes(results: { race: :event }) if @results_by_distance.empty? && @private_details
  end
end
