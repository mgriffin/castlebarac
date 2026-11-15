# frozen_string_literal: true

require "test_helper"

class ChildClaimTest < ActiveSupport::TestCase
  test "approving links the claimant as the child's parent" do
    claim = ChildClaim.create!(user: users(:bugs), child: people(:snori))

    claim.approve!(users(:admin))

    assert claim.approved?
    assert_equal users(:admin), claim.reviewed_by
    assert_not_nil claim.reviewed_at
    assert_includes people(:bugsbunny).children, people(:snori)
  end

  test "rejecting doesn't link them" do
    claim = ChildClaim.create!(user: users(:bugs), child: people(:snori))

    claim.reject!(users(:admin))

    assert claim.rejected?
    assert_empty people(:bugsbunny).children
  end

  test "approving a child who's been linked since is fine" do
    claim = ChildClaim.create!(user: users(:bugs), child: people(:snori))
    PersonRelationship.create!(parent: people(:bugsbunny), child: people(:snori))

    assert_no_difference -> { PersonRelationship.count } do
      claim.approve!(users(:admin))
    end
    assert claim.approved?
  end

  test "the claimant needs a person of their own" do
    claim = ChildClaim.new(user: users(:gabby), child: people(:snori))

    assert_not claim.valid?
    assert_includes claim.errors[:user], "needs to fill out their own details first"
  end

  test "they can't claim themselves or a child already linked to them" do
    PersonRelationship.create!(parent: people(:bugsbunny), child: people(:snori))

    assert_not ChildClaim.new(user: users(:bugs), child: people(:bugsbunny)).valid?
    assert_not ChildClaim.new(user: users(:bugs), child: people(:snori)).valid?
  end

  test "only one pending claim for the same child" do
    ChildClaim.create!(user: users(:bugs), child: people(:snori))

    assert_not ChildClaim.new(user: users(:bugs), child: people(:snori)).valid?
    assert ChildClaim.new(user: users(:coach), child: people(:snori)).valid?
  end
end
