# frozen_string_literal: true

require "test_helper"

module Admin
  class EventsControllerTest < ActionDispatch::IntegrationTest
    test "anonymous user can't load new event page" do
      get new_admin_event_url

      assert_response :not_found
    end

    test "logged in user can't load new event page" do
      sign_in :bugs

      get new_admin_event_url

      assert_response :not_found
    end

    test "admin user can load new event page" do
      sign_in :admin

      get new_admin_event_url

      assert_response :success
    end
  end
end
