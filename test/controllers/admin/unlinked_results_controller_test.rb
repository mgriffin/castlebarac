# frozen_string_literal: true

require "test_helper"

module Admin
  class UnlinkedResultsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @event = events(:first)
      race = @event.races.create!(name: "U9 Girls")
      @new_athlete = race.results.create!(name: "Juliette NIC SUIBHNE", club: "Castlebar A.C.", position: 1)
      @skipped = race.results.create!(name: "Not Wanted", club: "Castlebar A.C.", position: 2)
      @other_club = race.results.create!(name: "Someone Else", club: "Mayo AC", position: 3)
    end

    def people_params
      {
        people: {
          @new_athlete.id => { create: "1", firstname: "Juliette", surname: "Nic Suibhne" },
          @skipped.id => { create: "0", firstname: "Not", surname: "Wanted" }
        }
      }
    end

    test "only admins can see or add new athletes" do
      get admin_event_unlinked_results_url(@event)

      assert_response :not_found

      sign_in users(:bugs)

      assert_no_difference -> { Person.count } do
        post admin_event_unlinked_results_url(@event), params: people_params
      end
      assert_response :not_found
    end

    test "lists our unlinked results with their names filled in" do
      sign_in users(:admin)
      get admin_event_unlinked_results_url(@event)

      assert_response :success
      assert_select "input[name='people[#{@new_athlete.id}][create]'][checked]"
      assert_select "input[name='people[#{@new_athlete.id}][firstname]'][value=Juliette]"
      assert_select "input[name='people[#{@new_athlete.id}][surname]'][value='Nic Suibhne']"
      assert_select "input[name='people[#{@other_club.id}][create]']", count: 0
    end

    test "adds the ticked people and links their results" do
      sign_in users(:admin)

      assert_difference -> { Person.count } => 1 do
        post admin_event_unlinked_results_url(@event), params: people_params
      end

      assert_redirected_to event_url(@event)
      assert_equal "Added and linked 1 person", flash[:notice]
      assert_equal "Juliette Nic Suibhne", @new_athlete.reload.person.fullname
      assert_nil @skipped.reload.person
    end

    test "won't add people for results that aren't ours" do
      sign_in users(:admin)

      assert_no_difference -> { Person.count } do
        post admin_event_unlinked_results_url(@event),
             params: { people: { @other_club.id => { create: "1", firstname: "Someone", surname: "Else" } } }
      end
    end
  end
end
