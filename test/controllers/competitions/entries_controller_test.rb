# frozen_string_literal: true

require "test_helper"

module Competitions
  class EntriesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag

    test "you have to log in to enter" do
      get competition_entry_url(competitions(:connacht))

      assert_redirected_to new_user_session_url
    end

    test "shows an empty entry" do
      sign_in users(:bugs)

      get competition_entry_url(competitions(:connacht))

      assert_response :success
      assert_select "p", "You haven't entered anyone yet."
      assert_select "a", "Add an athlete"
    end

    test "shows who you've entered and the total" do
      sign_in users(:bugs)
      entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
      entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))
      entry.entry_lines.create!(person: people(:liam), competition_event: competition_events(:u12_boys_600m))

      get competition_entry_url(competitions(:connacht))

      assert_equal(["Ciara Walsh", "Liam Walsh"], css_select(".entry-athlete h2").map { it.text.strip })
      assert_select "li", /U12 Boys 600m\s+Not paid/
      assert_select "p", "To pay: €10.00"
      assert_select "a", "Add another athlete"
    end

    test "can't change an entry once entries close" do
      sign_in users(:bugs)

      get competition_entry_url(competitions(:nationals))

      assert_select "p", "Entries are closed, so this entry can't be changed."
      assert_select "a", text: "Add an athlete", count: 0
    end
  end
end
