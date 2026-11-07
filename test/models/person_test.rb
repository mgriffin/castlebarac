# frozen_string_literal: true

require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "creating a slug" do
    person = Person.new(firstname: "Bugs", surname: "O'Bunny")
    person.validate

    assert_equal "bugs-o-bunny", person.slug
  end

  test "changing a name changes the slug" do
    person = Person.new(firstname: "Bugs", surname: "O'Bunny")
    person.validate

    person.surname = "Bunny"
    person.validate

    assert_equal "bugs-bunny", person.slug
  end

  test "slug uses the transliterated version of a name" do
    person = Person.new(firstname: "Snörí", surname: "Snöríssøň")
    person.validate

    assert_equal "snori-snorisson", person.slug
  end

  test "can match a full name" do
    person = people(:snori)

    result = Person.match("Snörí Snöríssøň")

    assert_equal result, person
  end

  test "can match a full name with CAPITAL surname" do
    person = people(:snori)

    result = Person.match("Snörí SNÖRÍSSØŇ")

    assert_equal result, person
  end

  test "can match a full name with CAPITAL surname, reversed" do
    person = people(:snori)

    result = Person.match("SNÖRÍSSØŇ, Snörí")

    assert_equal result, person
  end

  test "results are grouped by distance, newest first, with no distance last" do
    person = people(:snori)
    old_race = Event.create!(title: "Old", start_time: 2.years.ago).races.create!(name: "Old")
    mid_race = Event.create!(title: "Mid", start_time: 1.year.ago).races.create!(name: "Mid")
    new_race = Event.create!(title: "New", start_time: 1.day.ago).races.create!(name: "New")

    old5k = person.results.create!(race: old_race, distance: 5000, position: 1)
    no_distance = person.results.create!(race: new_race, distance: nil, position: 1)
    new5k = person.results.create!(race: new_race, distance: 5000, position: 1)
    mid800 = person.results.create!(race: mid_race, distance: 800, position: 1)
    mid5k = person.results.create!(race: mid_race, distance: 5000, position: 1)
    old_no_distance = person.results.create!(race: old_race, distance: nil, position: 2)

    grouped = person.results_by_distance

    assert_equal [800, 5000, nil], grouped.keys
    assert_equal [mid800], grouped[800]
    assert_equal [new5k, mid5k, old5k], grouped[5000]
    assert_equal [no_distance, old_no_distance], grouped[nil]
  end
end
