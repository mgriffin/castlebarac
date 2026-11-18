# frozen_string_literal: true

require "test_helper"

module People
  class BirthYearsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "staff can fill in a missing year of birth and gender" do
      sign_in users(:coach)

      patch person_birth_year_url(people(:aoife)), params: { person: { year: "2016", gender: "female" } }

      assert_response :success
      assert_equal %w[2016 female], people(:aoife).reload.slice(:year, :gender).values
      assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(people(:aoife), :birth_year)}",
                    /2016\s+· #{people(:aoife).age_group}/
      assert_select "form", count: 0
    end

    test "says what's wrong" do
      sign_in users(:coach)

      patch person_birth_year_url(people(:aoife)), params: { person: { year: "16", gender: "female" } }

      assert_response :unprocessable_content
      assert_select ".text-danger", /Year of birth is invalid/
      assert_nil people(:aoife).reload.year
    end

    test "only fills in what's missing" do
      people(:aoife).update!(gender: "male")
      sign_in users(:coach)

      patch person_birth_year_url(people(:aoife)), params: { person: { year: "2016", gender: "female" } }

      assert_equal %w[2016 male], people(:aoife).reload.slice(:year, :gender).values
    end

    test "can't change details we already have" do
      sign_in users(:coach)

      patch person_birth_year_url(people(:ciara)), params: { person: { year: "2001" } }

      assert_response :not_found
      assert_not_equal "2001", people(:ciara).reload.year
    end

    test "only staff can fill them in" do
      sign_in users(:bugs)

      patch person_birth_year_url(people(:aoife)), params: { person: { year: "2016", gender: "female" } }

      assert_response :not_found
      assert_nil people(:aoife).reload.year
    end
  end
end
