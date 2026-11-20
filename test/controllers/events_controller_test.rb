# frozen_string_literal: true

require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::RecordIdentifier

  test "an event's results only look up the user's teams once" do
    30.times do |i|
      Result.create!(race: races(:one), name: "Runner #{i}", club: "Castlebar A.C.", person: people(:snori))
    end
    sign_in users(:admin)

    assert_queries_match(/FROM "teams"/, count: 1) do
      get event_path(events(:first))
    end

    assert_response :success
    assert_select "a[href^='/admin/results/']", 30
  end

  test "lists the races and marks the ones with Castlebar results" do
    other = Race.create!(event: events(:first), name: "U9 Girls 60m")
    Result.create!(race: races(:one), name: "Ours", club: "Castlebar A.C.", position: 1)
    Result.create!(race: races(:one), name: "Theirs", club: "Erris A.C.", position: 2)
    Result.create!(race: other, name: "Someone", club: "Erris A.C.", position: 1)

    get event_path(events(:first))

    assert_response :success
    assert_select ".event-header h2", "Something happening"
    assert_select ".event-header p", /2 races/
    assert_select ".race-jump a.race-chip", 2
    assert_select ".race-jump a.race-chip--club[href='##{dom_id(races(:one))}']", 1
    assert_select "section.race.race--club##{dom_id(races(:one))}" do
      assert_select ".race__club-count", "1 Castlebar"
      assert_select ".race__count", /2 results/
      assert_select "th.position abbr[title=Position]", "Pos"
      assert_select "tr.cbac .medal--1", "1"
    end
    assert_select "section.race:not(.race--club)##{dom_id(other)}"
  end

  test "offers a switch to show only Castlebar results" do
    Result.create!(race: races(:one), name: "Ours", club: "Castlebar A.C.", position: 1)

    get event_path(events(:first))

    assert_select "[data-controller=results-filter] .results-switch[hidden]" do
      assert_select "button.active[aria-pressed=true]", "All results"
      assert_select "button[aria-pressed=false][data-results-filter-club-only-param=true]", "Castlebar only"
    end
  end

  test "leaves out the switch when no Castlebar athletes ran" do
    Result.create!(race: races(:one), name: "Someone", club: "Erris A.C.", position: 1)

    get event_path(events(:first))

    assert_select ".results-switch", 0
    assert_select ".race__club-count", 0
  end

  test "leaves out the race list for a single race" do
    get event_path(events(:first))

    assert_select ".race-jump", 0
  end
end
