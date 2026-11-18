# frozen_string_literal: true

module Coaches
  # Juniors' ages, so coaches know which age group they're in
  class AthletesController < ApplicationController
    def index
      authorize :coach, :index?

      @people = Person.juniors.where(user_id: nil)
                      .order(Arel.sql("CAST(people.year AS INTEGER) DESC"), :surname, :firstname)
      @people = @people.without_birth_year if params[:missing] == "year"
      query = params.fetch(:q, "").to_s.strip
      @people = @people.search(query) if query.present?
    end
  end
end
