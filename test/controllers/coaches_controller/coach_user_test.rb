# frozen_string_literal: true

require "test_helper"

class CoachesController::CoachUserTest < ActionDispatch::IntegrationTest # rubocop:disable Style/ClassAndModuleChildren
  include Devise::Test::IntegrationHelpers

  test "can view the coaches page" do
    sign_in users(:coach)

    get coaches_url

    assert_response :success
  end
end
