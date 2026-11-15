# frozen_string_literal: true

require "test_helper"

class PersonClaimTest < ActiveSupport::TestCase
  test "approving links the person to the account" do
    claim = PersonClaim.create!(user: users(:gabby), person: people(:gabby))

    claim.approve!(users(:admin))

    assert claim.approved?
    assert_equal users(:admin), claim.reviewed_by
    assert_not_nil claim.reviewed_at
    assert_equal people(:gabby), users(:gabby).reload.person
  end

  test "approving a person someone else has by now changes nothing" do
    claim = PersonClaim.create!(user: users(:gabby), person: people(:snori))
    people(:snori).update!(user: users(:coach).tap { people(:coach).update!(user: nil) })

    assert_raises(ActiveRecord::RecordInvalid) { claim.approve!(users(:admin)) }

    assert claim.reload.pending?
    assert_nil users(:gabby).reload.person
    assert_equal users(:coach), people(:snori).reload.user
  end

  test "rejecting leaves the account without a person" do
    claim = PersonClaim.create!(user: users(:gabby), person: people(:gabby))

    claim.reject!(users(:admin))

    assert claim.rejected?
    assert_nil users(:gabby).reload.person
  end

  test "can't claim a person who already has an account" do
    claim = PersonClaim.new(user: users(:gabby), person: people(:admin))

    assert_not claim.valid?
    assert_includes claim.errors[:person], "has already been taken"
  end

  test "only one claim can wait for approval at a time" do
    PersonClaim.create!(user: users(:gabby), person: people(:gabby))
    PersonClaim.create!(user: users(:gabby), person: people(:snori), status: :rejected)

    assert_not PersonClaim.new(user: users(:gabby), person: people(:snori)).valid?
  end
end
