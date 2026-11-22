# frozen_string_literal: true

require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::RecordIdentifier

  setup do
    @event = Event.create!(title: "Race day", start_time: Time.zone.local(2026, 6, 7, 10))
  end

  test "shows results under distance headings, with other events last" do
    person = people(:snori)
    person.results.create!(race: @event.races.create!(name: "XC"), distance: nil, position: 3)
    person.results.create!(race: @event.races.create!(name: "5k"), distance: 5000, position: 2)
    person.results.create!(race: @event.races.create!(name: "800m"), distance: 800, position: 1)

    sign_in users(:gabby)
    get person_url(person)

    assert_response :success
    assert_equal(["800m", "5km", "Other events"], css_select(".person-results h3").map { it.text.strip })
    assert_select ".person-stats dd", text: "3", count: 2 # 3 results, 3 podiums
    assert_select ".person-results__race", text: "· XC"
  end

  test "marks the fastest time at a distance as a personal best, and gives the top three medals" do
    person = people(:snori)
    race = @event.races.create!(name: "60m")
    slow = person.results.create!(race:, distance: 60, position: 6, seconds: 9.85)
    fast = person.results.create!(race: Event.create!(title: "Later", start_time: 1.day.ago).races.create!(name: "60m"),
                                  distance: 60, position: 2, seconds: 9.62)

    sign_in users(:gabby)
    get person_url(person)

    assert_select "##{dom_id(fast)} .result", text: /9.62\s+PB/
    assert_select "##{dom_id(fast)} .medal--2", text: "2"
    assert_select "##{dom_id(slow)} .result", text: "9.85"
    assert_select "##{dom_id(slow)} .position", text: "6th"
  end

  test "shows the years someone was a member" do
    person = people(:snori)
    [2019, 2021, 2022, 2023].each { person.club_memberships.create!(year: it) }

    sign_in users(:gabby)
    get person_url(person)

    assert_select ".person-chip", text: "Member 2019, 2021–2023"
  end

  test "shows someone's age group and family to their parents" do
    sign_in users(:bugs)
    get person_url(people(:ciara))

    assert_select ".person-chip", text: people(:ciara).age_group
    assert_select ".person-header__family", text: /Child of Bugs Bunny/
  end

  test "hides someone's age group and family from everyone else" do
    sign_in users(:gabby)
    get person_url(people(:ciara))

    assert_response :success
    assert_select ".person-chip", count: 0
    assert_select ".person-header__family", count: 0
  end

  test "a parent without results sees their children instead" do
    people(:ciara).results.create!(race: @event.races.create!(name: "60m"), distance: 60, position: 4)

    sign_in users(:bugs)
    get person_url(people(:bugsbunny))

    assert_select ".person-child", count: 2
    assert_select ".person-child", text: /Ciara Walsh\s+#{people(:ciara).age_group}/
    assert_select ".person-child", text: /1 result, most recently\s+Race day on 7 Jun 2026/
    assert_select ".person-child", text: /Aoife Moran.*No results yet/m
    assert_select ".person-stats", count: 0
  end

  test "anyone else sees that a parent has no results" do
    sign_in users(:gabby)
    get person_url(people(:bugsbunny))

    assert_select ".person-child", count: 0
    assert_select ".person-empty", text: "No results yet."
  end
end
