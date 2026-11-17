# frozen_string_literal: true

require "test_helper"

module Admin
  module Competitions
    class EntriesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include CompetitionEntriesFlag
      include StripeHelpers

      test "lists the entries and downloads the paid ones" do
        sign_in users(:secretary)
        entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
        paid_entry_line(entry, people(:ciara), competition_events(:u12_girls_600m))
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

      test "lists the entries by event, then surname" do
        sign_in users(:secretary)
        people(:aoife).update!(year: people(:ciara).year, gender: "female")
        entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
        [%i[liam u12_boys_600m], %i[ciara u12_girls_80m], %i[aoife u12_girls_80m], %i[ciara u12_girls_600m]]
          .each do |person, event|
          paid_entry_line(entry, people(person), competition_events(event))
        end

        get admin_competition_entries_url(competitions(:connacht), format: :csv)

        rows = CSV.parse(response.body, headers: true).map { "#{it['Event']} #{it['Surname']}" }
        assert_equal ["U12 Girls 600m Walsh", "U12 Girls 80m Moran", "U12 Girls 80m Walsh", "U12 Boys 600m Walsh"], rows
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
