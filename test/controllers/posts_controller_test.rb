# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "anonymous user can load post index page" do
    get posts_url

    assert_response :success
  end
end
