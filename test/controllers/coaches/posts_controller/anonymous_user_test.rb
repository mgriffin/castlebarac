# frozen_string_literal: true

require "test_helper"

class Coaches::PostsController::AnonymousUserTest < ActionDispatch::IntegrationTest # rubocop:disable Style/ClassAndModuleChildren
  test "can not view the add coach post page" do
    get new_coaches_post_url

    assert_response :not_found
  end

  test "can not add a new coach post" do
    params = {
      coach_post: {
        title: Faker::String.random,
        content: Faker::Lorem.paragraph
      }
    }

    assert_no_difference "Coach::Post.count" do
      post coaches_posts_url, params:
    end

    assert_response :not_found
    assert_no_match(/^Added /, flash[:notice])
  end

  test "can not view a coach post" do
    post = coach_posts(:one)

    get coaches_post_url(post)

    assert_response :not_found
  end
end
