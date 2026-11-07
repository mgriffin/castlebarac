# frozen_string_literal: true

require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "shows results under distance headings, with other races last" do
    person = people(:snori)
    event = Event.create!(title: "Race day", start_time: 1.day.ago)
    person.results.create!(race: event.races.create!(name: "XC"), distance: nil, position: 3)
    person.results.create!(race: event.races.create!(name: "5k"), distance: 5000, position: 2)
    person.results.create!(race: event.races.create!(name: "800m"), distance: 800, position: 1)

    sign_in users(:bugs)
    get person_url(person)

    assert_response :success
    assert_equal(["800m", "5km", "Other races"], css_select(".content h3").map { |h3| h3.text.strip })
  end
end
