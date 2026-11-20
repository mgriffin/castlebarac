# frozen_string_literal: true

require "test_helper"

class ClubMembershipTest < ActiveSupport::TestCase
  test "someone is a member once a year" do
    ClubMembership.create!(person: people(:ciara), year: 2026)
    again = ClubMembership.new(person: people(:ciara), year: 2026)

    assert_not again.valid?
    assert ClubMembership.new(person: people(:ciara), year: 2025).valid?
  end

  test "needs a sensible year" do
    assert_not ClubMembership.new(person: people(:ciara), year: 26).valid?
  end

  test "lists the years anyone was a member, and this year, newest first" do
    ClubMembership.create!(person: people(:ciara), year: 2024)
    ClubMembership.create!(person: people(:liam), year: 2024)
    ClubMembership.create!(person: people(:liam), year: 2022)

    assert_equal [Date.current.year, 2024, 2022], ClubMembership.years
  end

  test "finds the members in a year" do
    ClubMembership.create!(person: people(:ciara), year: 2025)
    ClubMembership.create!(person: people(:ciara), year: 2026)
    ClubMembership.create!(person: people(:liam), year: 2025)

    assert_equal [people(:ciara)], Person.members_in(2026).to_a
    assert_equal [2025, 2026], people(:ciara).member_years
  end

  test "a member isn't unused" do
    person = Person.create!(firstname: "New", surname: "Member")

    assert_predicate person, :unused?

    ClubMembership.create!(person:, year: 2026)

    assert_not_predicate person, :unused?
  end

  test "AAI numbers are tidied and unique" do
    people(:ciara).update!(aai_number: " 477286 ")

    assert_equal "477286", people(:ciara).aai_number
    assert_not people(:liam).update(aai_number: "477286")
    assert people(:liam).update(aai_number: "  ")
    assert_nil people(:liam).aai_number
  end
end
