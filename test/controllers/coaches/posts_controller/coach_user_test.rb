# frozen_string_literal: true

require "test_helper"

class Coaches::PostsController::CoachUserTest < ActionDispatch::IntegrationTest # rubocop:disable Style/ClassAndModuleChildren
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in users(:coach)
  end

  test "can view the add coach post page" do
    get new_coaches_post_url

    assert_response :success
  end

  test "can add a new coach post" do
    params = {
      coach_post: {
        title: Faker::String.random,
        content: Faker::Lorem.paragraph
      }
    }

    assert_difference "Coach::Post.count" do
      post coaches_posts_url, params:
    end

    assert_redirected_to coaches_url
    assert_match(/^Added /, flash[:notice])
  end

  test "can view a coach post" do
    post = coach_posts(:one)

    get coaches_post_url(post)

    assert_response :success
  end
end
