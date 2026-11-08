# frozen_string_literal: true

require "test_helper"

class ResultLinkerTest < ActiveSupport::TestCase
  setup do
    @race = events(:first).races.create!(name: "U9 Girls")
  end

  def result(name, club: "Castlebar A.C.")
    @race.results.create!(name:, club:, position: 1)
  end

  test "links our club's results to people with the same name" do
    match = result("Snörí SNÖRÍSSØŇ")
    no_match = result("Someone New")
    other_club = result("Gabby Gabby", club: "Mayo AC")

    assert_equal [match], ResultLinker.new.link_matches

    assert_equal people(:snori), match.reload.person
    assert_nil no_match.reload.person
    assert_nil other_club.reload.person
    assert_equal [no_match], ResultLinker.new.unlinked.to_a
  end

  test "only looks at the results it's given" do
    elsewhere = Event.create!(title: "Other", start_time: Time.zone.now).races.create!(name: "x")
                     .results.create!(name: "Snörí Snöríssøň", club: "Castlebar A.C.", position: 1)
    mine = result("Snörí Snöríssøň")

    ResultLinker.new(Result.where(race: @race)).link_matches

    assert_equal people(:snori), mine.reload.person
    assert_nil elsewhere.reload.person
  end

  test "creates a person and links them" do
    new_result = result("Someone NEW")

    assert_difference -> { Person.count } => 1 do
      ResultLinker.link_to_new_person(new_result, firstname: "Someone", surname: "New")
    end

    assert_equal "Someone New", new_result.reload.person.fullname
  end

  test "uses the existing person rather than creating them twice" do
    assert_no_difference -> { Person.count } do
      ResultLinker.link_to_new_person(result("x"), firstname: "Snörí", surname: "Snöríssøň")
    end
  end
end
