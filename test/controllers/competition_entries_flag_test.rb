# frozen_string_literal: true

require "test_helper"

# Competition entries are hidden until the comp-entries flag is turned on
class CompetitionEntriesFlagTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "competition pages are not found while the flag is off" do
    sign_in users(:admin)

    [competitions_path, competition_path(competitions(:connacht)), competition_entry_path(competitions(:connacht)),
     admin_competitions_path, admin_competition_path(competitions(:connacht))].each do |path|
      get path

      assert_response :not_found, path
    end
  end

  test "competitions are hidden while the flag is off" do
    sign_in users(:admin)
    get admin_root_path

    assert_response :success
    assert_select "a[href='#{admin_competitions_path}']", count: 0

    get root_path

    assert_select ".competition-card", count: 0
  end

  test "the flag can be turned on for one user" do
    Flipper.enable_actor("comp-entries", users(:admin))

    get competitions_path

    assert_response :not_found

    sign_in users(:admin)
    get root_path

    assert_select ".competition-card h2 a", competitions(:connacht).name

    get admin_root_path

    assert_select "a[href='#{admin_competitions_path}']", "Competitions"

    get competitions_path

    assert_response :success
  end
end
