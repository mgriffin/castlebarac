# frozen_string_literal: true

require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "creating a slug" do
    person = Person.new(firstname: "Bugs", surname: "O'Bunny")
    person.validate

    assert_equal "bugs-o-bunny", person.slug
  end

  test "changing a name changes the slug" do
    person = Person.create!(firstname: "Bugs", surname: "O'Bunny")

    person.update!(surname: "Hare")

    assert_equal "bugs-hare", person.slug
  end

  test "people with the same name get different slugs" do
    second = Person.create!(firstname: "Bugs", surname: "Bunny")
    third = Person.create!(firstname: "Bugs", surname: "Bunny")

    assert_equal "bugs-bunny", people(:bugsbunny).slug
    assert_equal "bugs-bunny-2", second.slug
    assert_equal "bugs-bunny-3", third.slug
  end

  test "a slug only changes when the name does" do
    second = Person.create!(firstname: "Bugs", surname: "Bunny")

    second.update!(year: "2015")
    people(:bugsbunny).update!(gender: "M")

    assert_equal "bugs-bunny-2", second.reload.slug
    assert_equal "bugs-bunny", people(:bugsbunny).reload.slug
  end

  test "slug uses the transliterated version of a name" do
    person = Person.new(firstname: "Snörí", surname: "Björkssøň")
    person.validate

    assert_equal "snori-bjorksson", person.slug
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

  {
    "Juliette NIC SUIBHNE" => ["Juliette", "Nic Suibhne"],
    "Ella Marie MILTON" => ["Ella Marie", "Milton"],
    "Lucy O'Keeffe" => %w[Lucy O'Keeffe],
    "Jack O Brien" => ["Jack", "O Brien"],
    "Aoife NÍ BHRIAIN" => ["Aoife", "Ní Bhriain"],
    "Mary-Kate O'SULLIVAN" => %w[Mary-Kate O'Sullivan],
    "O'KEEFFE, Lucy" => %w[Lucy O'Keeffe],
    "Cher" => ["Cher", ""]
  }.each do |name, (firstname, surname)|
    test "splits #{name} into first name and surname" do
      assert_equal({ firstname:, surname: }, Person.split_name(name))
    end
  end
end
