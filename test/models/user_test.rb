# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "users without a person aren't in any teams" do
    user = users(:gabby)

    assert_nil user.person
    assert_empty user.teams
    assert_not user.admin?
    assert_not user.coach?
    assert_not user.committee?
  end

  test "users are in their person's teams" do
    assert users(:admin).admin?
    assert users(:coach).coach?
    assert_not users(:bugs).admin?
  end
end
