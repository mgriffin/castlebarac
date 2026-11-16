# frozen_string_literal: true

require "test_helper"

module Admin
  class CompetitionsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag

    test "only admins and committee members can manage competitions" do
      get admin_competitions_url

      assert_response :not_found

      sign_in users(:bugs)
      get admin_competitions_url

      assert_response :not_found

      sign_in users(:secretary)
      get admin_competitions_url

      assert_response :success
      assert_select "a", competitions(:connacht).name
    end

    test "links the committee to managing competitions from the menu" do
      sign_in users(:bugs)
      get root_url

      assert_select "#main-nav a[href=?]", admin_competitions_path, count: 0

      sign_in users(:secretary)
      get root_url

      assert_select "#main-nav a[href=?]", admin_competitions_path, "Manage competitions"
    end

    test "adds a competition with its events" do
      sign_in users(:secretary)

      assert_difference -> { Competition.count } => 1, -> { CompetitionEvent.count } => 2 do
        post admin_competitions_url, params: { competition: {
          name: "Mayo Juvenile Championships", level: "regional", venue: "Castlebar",
          date: "2027-05-16", entries_close_at: "2027-05-09T23:59", fee_per_event: "5.50",
          max_events_per_athlete: "2",
          competition_events_attributes: {
            "0" => { name: "U12 Girls 600m", distance: "600m", age_group: "U12", gender: "female" },
            "1" => { name: "U10 Relay", age_group: "U10", gender: "" },
            "2" => { name: "" }
          }
        } }
      end

      competition = Competition.last

      assert_redirected_to admin_competition_url(competition)
      assert_equal 550, competition.fee_per_event_cents
      assert_equal [11, "female"], competition.competition_events.first.slice(:min_age, :gender).values
      assert_nil competition.competition_events.last.gender
    end

    test "shows the errors when a competition isn't valid" do
      sign_in users(:admin)

      post admin_competitions_url, params: { competition: { name: "", level: "regional" } }

      assert_response :unprocessable_content
      assert_select ".alert-danger li", minimum: 1
    end

    test "removes an event" do
      sign_in users(:admin)
      competition = competitions(:connacht)
      event = competition_events(:u10_mixed_relay)

      patch admin_competition_url(competition), params: { competition: {
        competition_events_attributes: { "0" => { id: event.id, name: event.name, _destroy: "1" } }
      } }

      assert_redirected_to admin_competition_url(competition)
      assert_not CompetitionEvent.exists?(event.id)
    end

    test "shows a competition" do
      sign_in users(:admin)

      get admin_competition_url(competitions(:connacht))

      assert_response :success
      assert_select "td", "U12 Girls 600m"
      assert_select "button", "Close entries"
    end

    test "opens and closes entries" do
      sign_in users(:secretary)
      competition = competitions(:county)
      competition.update!(fee_per_event_cents: 500)
      competition.competition_events.create!(name: "U14 Boys 800m")

      post admin_competition_opening_url(competition)

      assert_redirected_to admin_competition_url(competition)
      assert_predicate competition.reload, :entries_open?

      delete admin_competition_opening_url(competition)

      assert_predicate competition.reload, :entries_closed?
    end

    test "says why entries can't be opened" do
      sign_in users(:admin)

      post admin_competition_opening_url(competitions(:county))

      assert_redirected_to admin_competition_url(competitions(:county))
      assert_match "Add at least one event", flash[:alert]
    end

    test "can't open entries if you're not on the committee" do
      sign_in users(:bugs)

      post admin_competition_opening_url(competitions(:county))

      assert_response :not_found
      assert_predicate competitions(:county).reload, :entries_draft?
    end

    test "deletes a competition with no entries" do
      sign_in users(:admin)

      assert_difference -> { Competition.count }, -1 do
        delete admin_competition_url(competitions(:county))
      end
    end
  end
end
