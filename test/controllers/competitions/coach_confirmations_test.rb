# frozen_string_literal: true

require "test_helper"

module Competitions
  # Events like hurdles and throws need whoever enters an athlete to confirm
  # they've discussed it with a club coach
  class CoachConfirmationsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include CompetitionEntriesFlag

    setup do
      @competition = competitions(:connacht)
      sign_in users(:bugs)
    end

    test "asks to confirm a coach's OK for events that need it" do
      get competition_entry_athlete_url(@competition, people(:ciara).id)

      hurdles = competition_events(:u12_girls_60m_hurdles)
      assert_select "input[name='confirmed_event_ids[]'][value=?]", hurdles.id.to_s
      assert_select "label[for=?]", "confirm_event_#{hurdles.id}",
                    /\AI confirm Ciara has discussed U12 Girls 60m Hurdles with a club coach and is ready/
      assert_select "input[name='confirmed_event_ids[]']", count: 1
    end

    test "won't enter them into an event that needs a coach's OK without it" do
      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: [competition_events(:u12_girls_60m_hurdles).id]
      }

      assert_response :unprocessable_content
      assert_select ".alert-danger li", "Confirm that Ciara has discussed U12 Girls 60m Hurdles with a club coach"
      assert_equal 0, EntryLine.count
    end

    test "enters them once a coach's OK is confirmed, recording who confirmed it" do
      hurdles = competition_events(:u12_girls_60m_hurdles)

      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: [hurdles.id], confirmed_event_ids: [hurdles.id]
      }

      assert_redirected_to competition_entry_url(@competition)
      line = EntryLine.sole
      assert_equal users(:bugs), line.confirmed_by
      assert_predicate line, :confirmed?
    end

    test "confirms a coach's OK for someone entered before the event needed it" do
      hurdles = competition_events(:u12_girls_60m_hurdles).tap { it.update!(requires_confirmation: false) }
      entry = Entry.create!(competition: @competition, user: users(:bugs))
      line = entry.entry_lines.create!(person: people(:ciara), competition_event: hurdles)
      hurdles.update!(requires_confirmation: true)

      patch competition_entry_athlete_url(@competition, people(:ciara).id), params: {
        competition_event_ids: [hurdles.id], confirmed_event_ids: [hurdles.id]
      }

      assert_redirected_to competition_entry_url(@competition)
      assert_predicate line.reload, :confirmed?
    end
  end
end
