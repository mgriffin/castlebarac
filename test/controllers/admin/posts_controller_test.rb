# frozen_string_literal: true

require "test_helper"

module Admin
  class PostsControllerTest < ActionDispatch::IntegrationTest
    test "anonymous user can't load new post page" do
      get new_admin_post_url

      assert_response :not_found
    end

    test "logged in user can't load new post page" do
      sign_in :bugs

      get new_admin_post_url

      assert_response :not_found
    end

    test "admin user can load new post page" do
      sign_in :admin

      get new_admin_post_url

      assert_response :success
    end

    test "anonymous user can't create new post" do
      post admin_posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

      assert_response :not_found
    end

    test "logged in user can't create new post" do
      sign_in :bugs

      post admin_posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

      assert_response :not_found
    end

    test "admin user can create new post" do
      sign_in :admin

      post admin_posts_url, params: { post: { title: Faker::String.random, body: Faker::Markdown.sandwich } }

      assert_redirected_to admin_post_url(Post.last.id)
    end

    test "anonymous user can't edit a post" do
      patch admin_post_url(Post.first.id), params: { post: { title: "edited the title" } }

      assert_response :not_found
    end

    test "logged in user can't edit a post" do
      sign_in :bugs

      patch admin_post_url(Post.first.id), params: { post: { title: "edited the title" } }

      assert_response :not_found
    end

    test "admin user can edit a post" do
      sign_in :admin

      patch admin_post_url(Post.first.id), params: { post: { title: "edited the title" } }

      assert_redirected_to admin_post_url(Post.first.id)
      assert_equal "edited the title", Post.first.title
    end
  end
end
