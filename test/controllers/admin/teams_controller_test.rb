# frozen_string_literal: true

require "test_helper"

module Admin
  class TeamsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "the team page adds members to that team and lets admins remove them" do
      sign_in users(:admin)

      get admin_team_url(teams(:coaches))

      assert_response :success
      assert_select "form[action='#{admin_team_memberships_path(teams(:coaches))}'] input[name='membership[person_id]']"
      assert_select "input[name='membership[team_id]']", count: 0
      membership = Membership.find_by(person: people(:coach), team: teams(:coaches))
      assert_select "form[action='#{admin_team_membership_path(teams(:coaches), membership)}'] " \
                    "input[name=_method][value=delete]"
    end

    test "admins can't remove themselves from the Admins team page" do
      sign_in users(:admin)

      get admin_team_url(teams(:admins))

      membership = Membership.find_by(person: people(:admin), team: teams(:admins))
      assert_select "form[action='#{admin_team_membership_path(teams(:admins), membership)}']", count: 0
      assert_select "li", text: /Ad Min\s+\(you\)/
    end

    test "unknown teams are not found" do
      sign_in users(:admin)

      get admin_team_url("no-such-team")

      assert_response :not_found
    end

    test "people who aren't admins can't see teams" do
      sign_in users(:bugs)

      get admin_team_url(teams(:coaches))

      assert_response :not_found
    end
  end
end
