# frozen_string_literal: true

require "test_helper"

class MailingListsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "logged out users can not see the mailing list" do
    get mailing_lists_url

    assert_response :not_found
  end

  test "regular users can not see the mailing list" do
    sign_in users(:bugs)

    get mailing_lists_url

    assert_response :not_found
  end

  test "admins can see the mailing list" do
    sign_in users(:admin)

    get mailing_lists_url

    assert_response :success
  end

  test "no one can sign up any more" do
    assert_no_difference("MailingList.count") do
      post mailing_lists_url, params: { mailing_list: { address: "bugs@acme.fake" } }
    end

    assert_response :not_found
    assert_enqueued_emails 0
  end
end
