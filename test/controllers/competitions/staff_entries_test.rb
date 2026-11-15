# frozen_string_literal: true

require "test_helper"

module Competitions
  # Admins, coaches and committee members can enter anyone, not just
  # themselves and their children
  class StaffEntriesTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

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
  end
end
