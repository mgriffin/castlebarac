# frozen_string_literal: true

require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "associate user with existing person" do
    gabby = users(:gabby)
    sign_in gabby
    gabby_profile = people(:gabby)

    assert_no_difference "Person.count" do
      post profile_url, params: { profile: {
        firstname: "Gabby",
        surname: "Gabby"
      } }
    end

    gabby.reload
    assert_equal gabby_profile.id, gabby.person.id
  end

  test "don't associate user with existing person if it doesn't match" do
    coach = users(:coach)
    sign_in coach

    assert_difference "Person.count" do
      post profile_url, params: { profile: {
        firstname: "Snori",
        surname: "Snorrisdottir"
      } }
    end
  end
end
