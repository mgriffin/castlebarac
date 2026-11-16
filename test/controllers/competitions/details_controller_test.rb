# frozen_string_literal: true

require "test_helper"

module Competitions
  class DetailsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag

    setup do
      @competition = competitions(:connacht)
      sign_in users(:bugs)
    end

    test "the year of birth has to look right" do
      patch competition_entry_athlete_details_url(@competition, people(:aoife).id),
            params: { person: { year: "15", gender: "female" } }

      assert_response :unprocessable_content
      assert_select ".alert-danger li", /Year of birth/
    end

    test "doesn't change details we already have" do
      patch competition_entry_athlete_details_url(@competition, people(:ciara).id),
            params: { person: { year: "2001", gender: "male" } }

      assert_equal "female", people(:ciara).reload.gender
    end
  end
end
