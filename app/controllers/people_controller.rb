# frozen_string_literal: true

class PeopleController < ApplicationController
  def show
    @person = Person.find_by!(slug: params.expect(:id))
    authorize @person
  end
end
