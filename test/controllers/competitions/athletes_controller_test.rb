# frozen_string_literal: true

require "test_helper"

module Competitions
  class AthletesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @competition = competitions(:connacht)
      sign_in users(:bugs)
    end

    test "offers you and your children" do
      get new_competition_entry_athlete_url(@competition)

      assert_response :success
      assert_equal ["Bugs Bunny", "Aoife Moran", "Ciara Walsh"], css_select("a.btn").map { it.text.strip }
      assert_select "a[href=?]", new_profile_child_claim_path
    end

    test "asks you to fill out your details if you haven't" do
      sign_in users(:gabby)

      get new_competition_entry_athlete_url(@competition)

      assert_select "a.btn", count: 0
      assert_select "a[href=?]", new_profile_path
    end

    test "can't enter someone who isn't your child" do
      liam = people(:liam)
      # sign_in only lasts past the first request if that one succeeds
      get competition_entry_url(@competition)

      get competition_entry_athlete_url(@competition, liam.id)
      assert_response :not_found

      patch competition_entry_athlete_url(@competition, liam.id),
            params: { competition_event_ids: [competition_events(:u12_boys_600m).id] }
      assert_response :not_found
      assert_equal 0, EntryLine.count

      delete competition_entry_athlete_url(@competition, liam.id)
      assert_response :not_found
    end

    test "can't set the details of someone who isn't your child" do
      liam = people(:liam).tap { it.update!(year: nil, gender: nil) }
      get competition_entry_url(@competition)

      patch competition_entry_athlete_details_url(@competition, liam.id),
            params: { person: { year: "2015", gender: "female" } }

      assert_response :not_found
      assert_nil liam.reload.year
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
