# frozen_string_literal: true

require "test_helper"

module Admin
  class MembersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "only admins and committee members can see the members" do
      get admin_members_url

      assert_response :not_found

      [users(:bugs), users(:coach)].each do |user|
        sign_in user
        get admin_members_url

        assert_response :not_found
      end

      [users(:admin), users(:secretary)].each do |user|
        sign_in user
        get admin_members_url

        assert_response :success
      end
    end

    test "lists this year's members" do
      people(:ciara).update!(aai_number: "477286")
      ClubMembership.create!(person: people(:ciara), year: Date.current.year)
      ClubMembership.create!(person: people(:liam), year: Date.current.year - 1)
      sign_in users(:secretary)

      get admin_members_url

      assert_select "h1", /Members in #{Date.current.year}/
      assert_select "tbody tr", 1
      assert_select "tbody td", "477286"
      assert_select "a[href='#{person_path(people(:ciara))}']", "Ciara Walsh"
      assert_select "nav a[aria-current=page]", Date.current.year.to_s
      assert_select "nav a[href='#{admin_members_path(year: Date.current.year - 1)}']"
    end

    test "lists another year's members" do
      ClubMembership.create!(person: people(:liam), year: 2024)
      sign_in users(:admin)

      get admin_members_url(year: 2024)

      assert_select "h1", /Members in 2024/
      assert_select "tbody tr", 1
      assert_select "a[href='#{person_path(people(:liam))}']"
    end

    test "says when nobody is on a year's list" do
      sign_in users(:admin)

      get admin_members_url(year: 2001)

      assert_select "p", "Nobody is on the member list for 2001 yet."
    end

    test "committee members get a link to the members" do
      sign_in users(:secretary)

      get root_url

      assert_select "#main-nav a[href='#{admin_members_path}']", "Members"
    end

    test "shows when an admin's person was a member" do
      people(:aoife).update!(aai_number: "123456")
      ClubMembership.create!(person: people(:aoife), year: 2025)
      ClubMembership.create!(person: people(:aoife), year: 2026)
      sign_in users(:admin)

      get edit_admin_person_url(people(:aoife))

      assert_select "p", /AAI number 123456\.\s+Member in 2025 and 2026\./
    end
  end
end
