# frozen_string_literal: true

require "test_helper"

module Admin
  module Competitions
    class EntriesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test "lists the entries and downloads the paid ones" do
        sign_in users(:secretary)
        entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
        entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m),
                                  paid_at: Time.current)
        entry.entry_lines.create!(person: people(:liam), competition_event: competition_events(:u12_boys_600m))

        get admin_competition_entries_url(competitions(:connacht))

        assert_response :success
        assert_select "td a", "Ciara Walsh"
        assert_select "td a", "Liam Walsh"
        assert_select ".badge", "Not paid"

        get admin_competition_entries_url(competitions(:connacht), format: :csv)

        assert_response :success
        assert_equal ["Event,First name,Surname,Gender,Year of birth,Entered by",
                      "U12 Girls 600m,Ciara,Walsh,female,#{people(:ciara).year},bugs@acme.fake"],
                     response.body.lines.map(&:chomp)
      end

      test "takes someone out of an event" do
        sign_in users(:admin)
        entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
        line = entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m))

        delete admin_competition_entry_line_url(competitions(:connacht), line)

        assert_redirected_to admin_competition_entries_url(competitions(:connacht))
        assert_not EntryLine.exists?(line.id)
      end
    end
  end
end
