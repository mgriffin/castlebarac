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
end
