# frozen_string_literal: true

require "test_helper"

class PersonFamilyTest < ActiveSupport::TestCase
  test "preloading a person's parents gives the right people" do
    children = people(:bugsbunny).children.includes(:parents).to_a

    assert_equal [[people(:bugsbunny)]], children.map { it.parents.to_a }.uniq
  end

  test "preloading a person's children gives the right people" do
    parent = Person.includes(:children).find(people(:bugsbunny).id)

    assert_equal [people(:aoife), people(:ciara)].sort_by(&:id), parent.children.sort_by(&:id)
  end

  test "a person's family relationships point back to them" do
    ciara = people(:ciara)
    bugs = people(:bugsbunny)

    assert_same ciara, ciara.parent_child_relationships.first.child
    assert_same bugs, bugs.child_parent_relationships.first.parent
  end
end
