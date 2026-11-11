# frozen_string_literal: true

require "test_helper"

module Admin
  class PeopleControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "only admins can see the list of people" do
      get admin_people_url

      assert_response :not_found

      sign_in users(:bugs)
      get admin_people_url

      assert_response :not_found
    end

    test "lists people by surname with their linked users" do
      sign_in users(:admin)

      get admin_people_url

      assert_response :success
      assert_equal(Person.order(:surname, :firstname).map(&:fullname),
                   css_select("tbody tr td:first-child a").map { |link| link.text.strip })
      assert_select "a[href='#{admin_user_path(users(:bugs))}']", users(:bugs).email
      assert_select "td", "–"
    end

    test "can edit everyone but yourself" do
      sign_in users(:admin)

      get admin_people_url

      assert_select "a[href='#{edit_admin_person_path(people(:bugsbunny))}']", "Edit"
      assert_select "a[href='#{edit_admin_person_path(people(:admin))}']", count: 0
      assert_select ".badge", "You"
    end
  end
end
