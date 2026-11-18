# frozen_string_literal: true

require "test_helper"

class CompetitorTest < ActiveSupport::TestCase
  test "the age group goes by age on 31 December" do
    person = Person.new(year: "2015")

    assert_equal "U12", person.age_group(on: Date.new(2026, 1, 1))
    assert_equal "U12", person.age_group(on: Date.new(2026, 12, 31))
    assert_equal "U13", person.age_group(on: Date.new(2027, 1, 1))
  end

  test "people are seniors from 20" do
    assert_equal "U20", Person.new(year: "2007").age_group(on: Date.new(2026, 6, 1))
    assert_equal "Senior", Person.new(year: "2006").age_group(on: Date.new(2026, 6, 1))
  end

  test "there's no age group without a year of birth" do
    assert_nil Person.new.age_group
    assert_nil Person.new(year: "15").age_group
  end

  test "finds people without a year of birth" do
    people(:snori).update_column(:year, "") # rubocop:disable Rails/SkipsModelValidations
    people(:gabby).update_column(:year, "fifteen") # rubocop:disable Rails/SkipsModelValidations

    missing = Person.without_birth_year

    assert_includes missing, people(:snori)
    assert_includes missing, people(:gabby)
    assert_includes missing, people(:aoife)
    assert_not_includes missing, people(:ciara)
  end
end
