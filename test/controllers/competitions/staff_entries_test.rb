# frozen_string_literal: true

require "test_helper"

module Competitions
  # Admins, coaches and committee members can enter anyone, not just
  # themselves and their children
  class StaffEntriesTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag

    setup do
      @competition = competitions(:connacht)
      sign_in users(:coach)
    end

    test "can search for anyone" do
      get new_competition_entry_athlete_url(@competition)
      assert_select "input[name=person_search]"
    end

    test "can enter someone who isn't their child" do
      post competition_entry_athletes_url(@competition), params: { person_id: people(:liam).id }
      assert_redirected_to competition_entry_athlete_url(@competition, people(:liam).id)

      patch competition_entry_athlete_url(@competition, people(:liam).id),
            params: { competition_event_ids: [competition_events(:u12_boys_600m).id] }
      assert_redirected_to competition_entry_url(@competition)
      assert_equal [people(:liam)], users(:coach).entries.find_by(competition: @competition).entry_lines.map(&:person)
    end

    test "asks them to choose someone if they didn't" do
      post competition_entry_athletes_url(@competition), params: { person_search: "Nobody", person_id: "" }

      assert_redirected_to new_competition_entry_athlete_url(@competition)
      assert_equal "Choose someone from the list", flash[:alert]
    end

    test "staff aren't asked for a coach's OK, and are recorded as giving it" do
      hurdles = competition_events(:u12_girls_60m_hurdles)
      get competition_entry_athlete_url(@competition, people(:ciara).id)

      assert_select "input[name='confirmed_event_ids[]']", count: 0
      assert_select ".small", /This event needs a club coach's OK. You'll be recorded as giving it./

      patch competition_entry_athlete_url(@competition, people(:ciara).id),
            params: { competition_event_ids: [hurdles.id, competition_events(:u12_girls_600m).id] }

      assert_redirected_to competition_entry_url(@competition)
      lines = users(:coach).entries.find_by(competition: @competition).entry_lines.index_by(&:competition_event)
      assert_equal users(:coach), lines[hurdles].confirmed_by
      assert_not_predicate lines[competition_events(:u12_girls_600m)], :confirmed?
    end
  end
end
