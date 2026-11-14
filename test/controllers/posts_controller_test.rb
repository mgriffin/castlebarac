# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def create_post(title = "New post")
    post posts_url, params: { post: { title:, content: "Hello" } }
  end

  def update_post(title = "Changed")
    patch post_url(posts(:one)), params: { post: { title: } }
  end

  test "anyone can read posts" do
    get posts_url
    assert_response :success

    get post_url(posts(:one))
    assert_response :success
  end

  test "unknown posts are not found" do
    get post_url("no-such-post")

    assert_response :not_found
  end

  test "anonymous visitors can't write or change posts" do
    get new_post_url
    assert_response :not_found

    assert_no_difference -> { Post.count } do
      create_post
    end
    assert_response :not_found

    get edit_post_url(posts(:one))
    assert_response :not_found

    update_post
    assert_response :not_found
    assert_equal "This is a title", posts(:one).reload.title
  end

  test "users who aren't admins or on the committee can't write or change posts" do
    sign_in users(:bugs)

    get new_post_url
    assert_response :not_found

    assert_no_difference -> { Post.count } do
      create_post
    end
    assert_response :not_found

    update_post
    assert_response :not_found
    assert_equal "This is a title", posts(:one).reload.title
  end

  test "admins can write and change posts" do
    sign_in users(:admin)

    assert_difference -> { Post.count } => 1 do
      create_post
    end
    assert_equal users(:admin), Post.last.user

    update_post
    assert_equal "Changed", posts(:one).reload.title
  end

  test "committee members can write and change posts" do
    make_committee_member(users(:bugs))
    sign_in users(:bugs)

    get new_post_url
    assert_response :success

    assert_difference -> { Post.count } => 1 do
      create_post
    end

    get edit_post_url(posts(:one))
    assert_response :success

    update_post
    assert_equal "Changed", posts(:one).reload.title
  end

  test "only people who can write posts see the link to add one" do
    get posts_url
    assert_select "a[href='#{new_post_path}']", count: 0

    sign_in users(:admin)
    get posts_url
    assert_select "a[href='#{new_post_path}']"
  end
end
