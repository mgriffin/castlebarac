# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "anonymous user can't load new post page" do
    get new_post_url

    assert_response :forbidden
  end

  test "logged in user can load new post page" do
    sign_in :bugs

    get new_post_url

    assert_response :success
  end

  test "anonymous user can't create new post" do
    post posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

    assert_response :forbidden
  end

  test "logged in user can create new post" do
    sign_in :bugs

    post posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

    assert_redirected_to post_url(Post.last)
  end

  test "anonymous user can't edit a post" do
    patch post_url(Post.first.id), params: { post: { title: "edited the title" } }

    assert_response :forbidden
  end

  test "logged in user can edit a post" do
    sign_in :bugs

    patch post_url(Post.first.id), params: { post: { title: "edited the title" } }

    assert_redirected_to post_url(Post.first)
    assert_equal "edited the title", Post.first.title
  end
end
