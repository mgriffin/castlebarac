# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "anonymous user can't load new post page" do
    get new_post_url

    assert_response :not_found
  end

  test "logged in user can't load new post page" do
    sign_in :bugs

    get new_post_url

    assert_response :success
  end

  test "admin user can load new post page" do
    sign_in :admin

    get new_post_url

    assert_response :success
  end

  test "anonymous user can't create new post" do
    post posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

    assert_response :not_found
  end

  test "logged in user can't create new post" do
    sign_in :bugs

    post posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

    assert_redirected_to post_url(Post.last)
  end

  test "admin user can create new post" do
    sign_in :admin

    post posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

    assert_redirected_to post_url(Post.last)
  end

  test "anonymous user can't edit a post" do
    patch post_url(Post.first.id), params: { post: { title: "edited the title" } }

    assert_response :not_found
  end

  test "logged in user can't edit a post" do
    sign_in :bugs

    patch post_url(Post.first.id), params: { post: { title: "edited the title" } }

    assert_redirected_to post_url(Post.first)
    assert_equal "edited the title", Post.first.title
  end

  test "admin user can edit a post" do
    sign_in :admin

    patch post_url(Post.first.id), params: { post: { title: "edited the title" } }

    assert_redirected_to post_url(Post.first)
    assert_equal "edited the title", Post.first.title
  end
end
