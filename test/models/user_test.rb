# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "users without a person aren't in any teams" do
    user = users(:gabby)

    assert_nil user.person
    assert_empty user.teams
    assert_not user.admin?
  end

  test "users are in their person's teams" do
    assert users(:admin).admin?
    assert users(:coach).coach?
    assert_not users(:bugs).admin?
  end

  test "admins, coaches and committee members are staff" do
    assert users(:admin).staff?
    assert users(:coach).staff?
    assert_not users(:bugs).staff?
    assert_not users(:gabby).staff?

    make_committee_member(users(:bugs))
    assert users(:bugs).staff?
  end
end
