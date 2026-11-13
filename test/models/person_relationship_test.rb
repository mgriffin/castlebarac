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
end
