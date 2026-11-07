# frozen_string_literal: true

require "test_helper"

module Admin
  class ResultsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @result = events(:first).races.create!(name: "Girls")
                              .results.create!(name: "Snörí SNÖRÍSSØŇ", club: "Castlebar A.C.", position: 1)
    end

    def link_params(person_id)
      { result: { person: "Snörí Snöríssøň", person_id:, id: @result.id } }
    end

    test "admin can link a result to a person" do
      sign_in users(:admin)
      patch admin_result_url(@result), params: link_params(people(:snori).id)

      assert_redirected_to event_url(events(:first))
      assert_equal "Linked result to Snörí Snöríssøň", flash[:notice]
      assert_equal people(:snori), @result.reload.person
    end

    test "linking to someone who doesn't exist says so" do
      sign_in users(:admin)
      patch admin_result_url(@result), params: link_params(0)

      assert_redirected_to event_url(events(:first))
      assert_equal "Snörí Snöríssøň wasn't found", flash[:notice]
      assert_nil @result.reload.person
    end

    test "non-admins can't link results" do
      sign_in users(:bugs)
      patch admin_result_url(@result), params: link_params(people(:snori).id)

      assert_response :not_found
      assert_nil @result.reload.person
    end
  end
end
