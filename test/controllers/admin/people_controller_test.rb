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

    test "shows each person's year of birth and age group" do
      sign_in users(:admin)

      get admin_people_url

      assert_select "tr", text: /Ciara Walsh/ do
        assert_select "td", /#{people(:ciara).year}\s+· #{people(:ciara).age_group}/
      end
      assert_select "tr", text: /Aoife Moran/ do
        assert_select "form[action='#{person_birth_year_path(people(:aoife))}'] input[name='person[year]']"
      end
    end

    test "lists the people missing a year of birth" do
      sign_in users(:admin)

      get admin_people_url(missing: "year")

      names = css_select("tbody tr td:first-child a").map { |link| link.text.strip }

      assert_includes names, "Aoife Moran"
      assert_not_includes names, "Ciara Walsh"
      assert_select "a", "Show everyone"
    end

    test "sets someone's year of birth and gender" do
      sign_in users(:admin)

      patch admin_person_url(people(:aoife)), params: { person: { year: "2016", gender: "female" } }

      assert_redirected_to admin_people_url
      assert_equal %w[2016 female], people(:aoife).reload.slice(:year, :gender).values
    end

    test "a year of birth can be cleared but has to look right" do
      sign_in users(:admin)

      patch admin_person_url(people(:ciara)), params: { person: { year: "", gender: "" } }

      assert_nil people(:ciara).reload.year
      assert_nil people(:ciara).gender

      patch admin_person_url(people(:ciara)), params: { person: { year: "15" } }

      assert_response :unprocessable_content
    end

    test "keeps a gender it doesn't know" do
      people(:aoife).update!(gender: "M")
      sign_in users(:admin)

      get edit_admin_person_url(people(:aoife))

      assert_select "select#person_gender option[selected]", "M"
    end
  end
end
