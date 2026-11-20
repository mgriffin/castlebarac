# frozen_string_literal: true

require "test_helper"

class MemberListImportTest < ActiveSupport::TestCase
  setup do
    people(:ciara).update!(year: "2015", gender: nil)
    people(:liam).update!(year: "2015")
  end

  # e.g. row("400001", "Ciara Walsh", 2015)
  def row(aai_number, name, year, gender = "female", problem: nil)
    firstname, surname = name.split(" ", 2)
    MemberList::Row.new(aai_number:, firstname:, surname:, year:, gender:, problem:)
  end

  def import(*rows, year: 2026, choices: {})
    MemberListImport.new(rows:, year:, choices:)
  end

  test "matches people by name and year of birth, and fills in their details" do
    list = import(row("400001", "Ciara Walsh", 2015))
    entry = list.entries.first

    assert_equal :update, entry.status
    assert_equal people(:ciara), entry.person
    assert_equal ["Add to the 2026 list", "Set the AAI number to 400001", "Set the gender to female"], entry.changes

    assert_equal({ added: 0, updated: 1, removed: 0 }, list.apply!)
    assert_equal "400001", people(:ciara).reload.aai_number
    assert_equal "female", people(:ciara).gender
    assert_equal [2026], people(:ciara).member_years
  end

  test "matches people by AAI number once they have one, whatever their name" do
    people(:aoife).update!(aai_number: "400005")

    entry = import(row("400005", "Aoife Moran-Kelly", 2014)).entries.first

    assert_equal people(:aoife), entry.person
    assert_includes entry.changes, "Set the year of birth to 2014"
  end

  test "adds people nobody on the site matches" do
    list = import(row("400002", "NIAMH Ó SÚILLEABHÁIN", 2016))

    assert_equal :new, list.entries.first.status
    assert_difference -> { Person.count } do
      assert_equal({ added: 1, updated: 0, removed: 0 }, list.apply!)
    end

    person = Person.find_by!(aai_number: "400002")

    assert_equal "Niamh Ó Súilleabháin", person.fullname
    assert_equal %w[2016 female], [person.year, person.gender]
    assert_equal [2026], person.member_years
  end

  test "picks the person with the same year of birth" do
    dad = Person.create!(firstname: "Liam", surname: "Walsh", year: "1980")

    entry = import(row("400004", "Liam Walsh", 2015, "male")).entries.first

    assert_equal people(:liam), entry.person
    assert_not_equal dad, entry.person
  end

  test "asks an admin when the year of birth on the site is different, or more than one person fits" do
    different_year = import(row("400001", "Ciara Walsh", 2016)).entries.first
    twin = Person.create!(firstname: "Ciara", surname: "Walsh")
    two = import(row("400001", "Ciara Walsh", 2015)).entries.first

    assert_equal [:choose, [people(:ciara)]], [different_year.status, different_year.candidates]
    assert_equal [:choose, [people(:ciara), twin]], [two.status, two.candidates.sort_by(&:id)]
  end

  test "does what an admin chose" do
    Person.create!(firstname: "Ciara", surname: "Walsh")
    rows = [row("400001", "Ciara Walsh", 2015)]

    chosen = import(*rows, choices: { "400001" => people(:ciara).id.to_s }).entries.first
    added = import(*rows, choices: { "400001" => MemberListImport::NEW }).entries.first
    left_out = import(*rows, choices: { "400001" => MemberListImport::LEAVE_OUT }).entries.first
    someone_else = import(*rows, choices: { "400001" => people(:aoife).id.to_s }).entries.first

    assert_equal [:update, people(:ciara)], [chosen.status, chosen.person]
    assert_equal :new, added.status
    assert_equal :left_out, left_out.status
    assert_equal :choose, someone_else.status
  end

  test "doesn't match two rows to one person" do
    entries = import(row("400001", "Ciara Walsh", 2015), row("400009", "Ciara Walsh", 2015)).entries

    assert_equal %i[update new], entries.map(&:status)
  end

  test "leaves out rows it can't use, and a Reg Life ID that's on the list twice" do
    entries = import(row("", "Ciara Walsh", 2015, problem: "There's no Reg Life ID"),
                     row("400004", "Liam Walsh", 2015, "male"),
                     row("400004", "Liam Walsh", 2015, "male")).entries

    assert_equal %i[problem update problem], entries.map(&:status)
    assert_equal "This Reg Life ID is on the list twice", entries.last.problem
  end

  test "takes people off the year's list when they're not on it, without deleting them" do
    ClubMembership.create!(person: people(:aoife), year: 2026)
    ClubMembership.create!(person: people(:aoife), year: 2025)
    list = import(row("400001", "Ciara Walsh", 2015))

    assert_equal [people(:aoife)], list.leavers.to_a
    assert_equal({ added: 0, updated: 1, removed: 1 }, list.apply!)
    assert_equal [2025], people(:aoife).member_years
  end

  test "importing the same list again changes nothing" do
    rows = [row("400001", "Ciara Walsh", 2015), row("400002", "Niamh Ó Súilleabháin", 2016),
            row("400004", "Liam Walsh", 2015, "male")]
    import(*rows).apply!
    before = [Person.order(:id).pluck(:id, :updated_at), ClubMembership.order(:id).pluck(:id, :updated_at)]

    again = import(*rows)

    assert_equal %i[up_to_date] * 3, again.entries.map(&:status)
    assert_not again.changes?
    assert_equal({ added: 0, updated: 0, removed: 0 }, again.apply!)
    assert_equal before, [Person.order(:id).pluck(:id, :updated_at), ClubMembership.order(:id).pluck(:id, :updated_at)]
  end

  test "another year's list is kept separately" do
    rows = [row("400001", "Ciara Walsh", 2015)]
    import(*rows, year: 2025).apply!

    entry = import(*rows, year: 2026).entries.first

    assert_equal ["Add to the 2026 list"], entry.changes
  end
end
