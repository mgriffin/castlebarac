# frozen_string_literal: true

require "test_helper"

class AccountLinkerTest < ActiveSupport::TestCase
  test "links an account that has no person" do
    AccountLinker.link!(people(:snori), users(:gabby))

    assert_equal people(:snori), users(:gabby).reload.person
  end

  test "linking replaces the account's own person when it's unused" do
    own = Person.create!(firstname: "Gabby", surname: "Gabby", user: users(:gabby))

    AccountLinker.link!(people(:gabby), users(:gabby))

    assert_equal people(:gabby), users(:gabby).reload.person
    assert_not Person.exists?(own.id)
  end

  test "linking leaves the account's own person alone when it has results" do
    own = Person.create!(firstname: "Gabby", surname: "Gabby", user: users(:gabby))
    events(:first).races.create!(name: "U9").results.create!(name: "Gabby Gabby", person: own)

    error = assert_raises(ActiveRecord::RecordInvalid) { AccountLinker.link!(people(:gabby), users(:gabby)) }

    assert_includes error.message, "gabbygabby@acme.fake is already linked to Gabby Gabby"
    assert_equal own, users(:gabby).reload.person
    assert_nil people(:gabby).reload.user
  end

  test "won't link a person who already has an account" do
    error = assert_raises(ActiveRecord::RecordInvalid) { AccountLinker.link!(people(:bugsbunny), users(:gabby)) }

    assert_includes error.message, "Bugs Bunny is already linked to another account"
    assert_equal users(:bugs), people(:bugsbunny).reload.user
    assert_nil users(:gabby).reload.person
  end

  test "linking the account a person already has changes nothing" do
    assert_no_difference -> { Person.count } do
      AccountLinker.link!(people(:bugsbunny), users(:bugs))
    end

    assert_equal users(:bugs), people(:bugsbunny).reload.user
  end
end
