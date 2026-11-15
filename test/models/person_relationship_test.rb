# frozen_string_literal: true

require "test_helper"

class PersonRelationshipTest < ActiveSupport::TestCase
  test "a declared link is marked as self declared" do
    link = PersonRelationship.declare(parent: people(:bugsbunny), child: people(:liam))

    assert_predicate link, :self_declared?
  end

  test "declaring an existing link leaves it alone" do
    assert_no_difference -> { PersonRelationship.count } do
      link = PersonRelationship.declare(parent: people(:bugsbunny), child: people(:ciara))

      assert_not link.self_declared?
    end
  end

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

  test "the database won't link a parent and child twice either" do
    PersonRelationship.create!(parent: people(:bugsbunny), child: people(:snori))

    assert_raises(ActiveRecord::RecordNotUnique) do
      PersonRelationship.new(parent: people(:bugsbunny), child: people(:snori)).save(validate: false)
    end
  end
end
