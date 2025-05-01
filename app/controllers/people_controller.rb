# frozen_string_literal: true

class PeopleController < ApplicationController
  def show
    @person = Person.find_by(slug: params[:id])
    authorize @person
  end
end
