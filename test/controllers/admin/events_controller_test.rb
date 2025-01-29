# frozen_string_literal: true

require "test_helper"

module Admin
  class EventsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "anonymous user can't load new event page" do
      get new_admin_event_url

      assert_response :not_found
    end

    test "logged in user can't load new event page" do
      sign_in users(:bugs)

      get new_admin_event_url

      assert_response :not_found
    end

    test "admin user can load new event page" do
      sign_in users(:admin)

      get new_admin_event_url

      assert_response :success
    end

    test "anonymous user can't create new event" do
      post admin_events_url,
           params: { event: { title: Faker::String.random, start_time: DateTime.now, body: Faker::Markdown.sandwich } }

      assert_response :not_found
    end

    test "logged in user can't create new event" do
      sign_in users(:bugs)

      post admin_events_url,
           params: { event: { title: Faker::String.random, start_time: DateTime.now, body: Faker::Markdown.sandwich } }

      assert_response :not_found
    end

    test "admin user can create new event" do
      sign_in users(:admin)

      post admin_events_url,
           params: { event: { title: Faker::String.random, start_time: DateTime.now, body: Faker::Markdown.sandwich } }

      assert_redirected_to admin_event_url(Event.last)
    end

    test "anonymous user can't edit a event" do
      patch admin_event_url(Event.first.id), params: { event: { title: "edited the title" } }

      assert_response :not_found
    end

    test "logged in user can't edit a event" do
      sign_in users(:bugs)

      patch admin_event_url(Event.first.id), params: { event: { title: "edited the title" } }

      assert_response :not_found
    end

    test "admin user can edit a event" do
      sign_in users(:admin)

      patch admin_event_url(Event.first), params: { event: { title: "edited the title" } }

      assert_redirected_to admin_event_url(Event.first)
      assert_equal "edited the title", Event.first.title
    end
  end
end
