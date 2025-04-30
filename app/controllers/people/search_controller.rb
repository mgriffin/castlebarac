# frozen_string_literal: true

module People
  class SearchController < ApplicationController
    def index
      @people = Person.search(params[:q])
      render layout: false
    end
  end
end
