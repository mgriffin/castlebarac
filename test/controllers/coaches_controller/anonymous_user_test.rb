# frozen_string_literal: true

require "test_helper"

class CoachesController::AnonymousUserTest < ActionDispatch::IntegrationTest # rubocop:disable Style/ClassAndModuleChildren
  test "can not view the coaches page" do
    get coaches_url

    assert_response :not_found
  end
end
