# frozen_string_literal: true

module Admin
  class PeopleController < ApplicationController
    before_action :set_person, only: %i[edit update]

    # GET /admin/people
    def index
      @people = Person.all
    end

    # GET /admin/people/new
    def new
      @person = Person.new
    end

    # GET /admin/people/1/edit
    def edit; end

    # POST /admin/people
    def create
      @person = Person.new(person_params)

      if @person.save
        redirect_to admin_people_path, notice: "Added #{@person.firstname} #{@person.surname}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/people/1
    def update
      if @person.update(person_params)
        redirect_to admin_people_path, notice: "Edited #{@person.firstname} #{@person.surname}", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.require(:person).permit(:firstname, :surname)
    end
  end
end