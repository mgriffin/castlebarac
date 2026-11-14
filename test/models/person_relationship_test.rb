# frozen_string_literal: true

require "test_helper"

class PersonRelationshipTest < ActiveSupport::TestCase
  test "a parent and child can only be linked once" do
    PersonRelationship.create!(parent: people(:bugsbunny), child: people(:snori))

    duplicate = PersonRelationship.new(parent: people(:bugsbunny), child: people(:snori))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:child_id], "is already linked to this parent"
  end

  test "someone can't be their own parent" do
    relationship = PersonRelationship.new(parent: people(:bugsbunny), child: people(:bugsbunny))

    assert_not relationship.valid?
    assert_includes relationship.errors[:child], "can't be the same person as the parent"
  end
end
