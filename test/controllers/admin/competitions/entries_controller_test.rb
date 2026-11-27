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
        assert_equal ["Event,First name,Surname,Gender,Year of birth,Entered by,Coach's OK",
                      "U12 Girls 600m,Ciara,Walsh,female,#{people(:ciara).year},Bugs Bunny,"],
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

      test "shows who confirmed a coach's OK, and who still needs one" do
        sign_in users(:secretary)
        entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
        hurdles = competition_events(:u12_girls_60m_hurdles)
        line = entry.entry_lines.build(person: people(:ciara), competition_event: hurdles)
        line.confirm(users(:bugs))
        pay_for(line.tap(&:save!))
        long_jump = competition_events(:u12_girls_long_jump)
        pay_for(entry.entry_lines.create!(person: people(:ciara), competition_event: long_jump))
        long_jump.update!(requires_confirmation: true)

        get admin_competition_entries_url(competitions(:connacht))

        assert_select "td", /bugs@acme.fake\s+#{Regexp.escape(I18n.l(line.reload.confirmed_at, format: :short))}/
        assert_select ".badge", "Not confirmed"

        get admin_competition_entries_url(competitions(:connacht), format: :csv)

        rows = CSV.parse(response.body, headers: true).to_h { [it["Event"], it["Coach's OK"]] }
        assert_match(/\Abugs@acme.fake /, rows["U12 Girls 60m Hurdles"])
        assert_equal "Not confirmed", rows["U12 Girls Long Jump"]
      end
    end
  end
end
