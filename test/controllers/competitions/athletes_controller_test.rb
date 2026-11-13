# frozen_string_literal: true

require "test_helper"

module Competitions
  class AthletesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @competition = competitions(:connacht)
      sign_in users(:bugs)
    end

    test "offers you and your children first" do
      get new_competition_entry_athlete_url(@competition)

      assert_response :success
      assert_equal(["Bugs Bunny", "Ciara Walsh"], css_select("form button").map { it.text.strip })
    end

    test "goes straight to the events for your child" do
      post competition_entry_athletes_url(@competition), params: { person_id: people(:ciara).id }

      assert_redirected_to competition_entry_athlete_url(@competition, people(:ciara).id)
    end

    test "asks if someone else is your child" do
      post competition_entry_athletes_url(@competition), params: { person_id: people(:liam).id }

      assert_redirected_to new_competition_entry_athlete_url(@competition, person_id: people(:liam).id)
      follow_redirect!

      assert_select "h1", "Is Liam Walsh your child?"
    end

    test "asks you to choose someone if you didn't" do
      post competition_entry_athletes_url(@competition), params: { person_search: "Nobody", person_id: "" }

      assert_redirected_to new_competition_entry_athlete_url(@competition)
      assert_equal "Choose someone from the list", flash[:alert]
    end

    test "links your child if you say so" do
      assert_difference -> { PersonRelationship.count } do
        post competition_entry_athletes_url(@competition), params: { person_id: people(:liam).id, child: "yes" }
      end

      assert_redirected_to competition_entry_athlete_url(@competition, people(:liam).id)
      assert_includes people(:bugsbunny).children, people(:liam)
      assert PersonRelationship.find_by(child: people(:liam)).self_declared
    end

    test "can enter someone who isn't your child" do
      assert_no_difference -> { PersonRelationship.count } do
        post competition_entry_athletes_url(@competition), params: { person_id: people(:liam).id, child: "no" }
      end

      assert_redirected_to competition_entry_athlete_url(@competition, people(:liam).id)
    end

    test "shows the events they can enter" do
      get competition_entry_athlete_url(@competition, people(:ciara).id)

      assert_response :success
      assert_select "label", /U12 Girls 600m/
      assert_select "label", text: /U12 Boys 600m/, count: 0
      assert_select "p", /up to\s+2 events/
    end

    test "asks for a year of birth and gender first" do
      get competition_entry_athlete_url(@competition, people(:aoife).id)

      assert_select "h1", "About Aoife Moran"

      patch competition_entry_athlete_details_url(@competition, people(:aoife).id),
            params: { person: { year: people(:ciara).year, gender: "female" } }

      assert_redirected_to competition_entry_athlete_url(@competition, people(:aoife).id)
      assert_predicate people(:aoife).reload, :entry_details_complete?
    end

    test "enters them into events" do
      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: ["", competition_events(:u12_girls_600m).id, competition_events(:u12_girls_80m).id]
      }

      assert_redirected_to competition_entry_url(@competition)
      entry = users(:bugs).entries.find_by(competition: @competition)

      assert_equal %w[u12_girls_600m u12_girls_80m].map { competition_events(it) },
                   entry.entry_lines.map(&:competition_event).sort_by(&:position)
    end

    test "changes their events" do
      entry = Entry.create!(competition: @competition, user: users(:bugs))
      entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))

      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: ["", competition_events(:u12_girls_long_jump).id]
      }

      assert_equal [competition_events(:u12_girls_long_jump)], entry.reload.entry_lines.map(&:competition_event)
    end

    test "won't go over the event limit" do
      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: %i[u12_girls_600m u12_girls_long_jump u12_girls_80m].map { competition_events(it).id }
      }

      assert_response :unprocessable_content
      assert_select ".alert-danger li", "Ciara can only be entered into 2 events"
      assert_equal 0, EntryLine.count
    end

    test "removes someone from the entry" do
      entry = Entry.create!(competition: @competition, user: users(:bugs))
      entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))

      delete competition_entry_athlete_url(@competition, people(:ciara).id)

      assert_redirected_to competition_entry_url(@competition)
      assert_empty entry.entry_lines.reload
    end

    test "can't enter anyone after entries close" do
      patch competition_entry_athlete_url(competitions(:nationals), people(:ciara).id), params: {
        competition_event_ids: [competition_events(:nationals_u12_girls_600m).id]
      }

      assert_redirected_to competition_entry_url(competitions(:nationals))
      assert_equal "Entries for this competition are closed", flash[:alert]
      assert_equal 0, EntryLine.count
    end
  end
end
