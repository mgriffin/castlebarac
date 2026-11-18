# frozen_string_literal: true

require "test_helper"

module Coaches
  class AthletesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "only staff can see athletes' ages" do
      get coaches_athletes_url

      assert_response :not_found

      sign_in users(:bugs)
      get coaches_athletes_url

      assert_response :not_found
    end

    test "lists juniors who aren't members with their ages" do
      people(:snori).update!(year: (Date.current.year - Competitor::SENIOR_AGE).to_s)
      sign_in users(:coach)

      get coaches_athletes_url

      assert_response :success
      names = css_select("tbody tr td:first-child a").map { it.text.strip }

      assert_includes names, "Ciara Walsh"
      assert_includes names, "Aoife Moran"
      assert_not_includes names, "Snörí Snöríssøň", "seniors aren't listed"
      assert_not_includes names, "Bugs Bunny", "adult members aren't listed"
      assert_select "tr", text: /Ciara Walsh/ do
        assert_select "td", /#{people(:ciara).year}\s+· #{people(:ciara).age_group}/
      end
    end

    test "lists the people missing a year of birth" do
      sign_in users(:coach)

      get coaches_athletes_url(missing: "year")

      names = css_select("tbody tr td:first-child a").map { it.text.strip }

      assert_includes names, "Aoife Moran"
      assert_not_includes names, "Ciara Walsh"
    end

    test "searches by name" do
      sign_in users(:coach)

      get coaches_athletes_url(q: "aoi")

      assert_equal(["Aoife Moran"], css_select("tbody tr td:first-child a").map { it.text.strip })
    end
  end
end
