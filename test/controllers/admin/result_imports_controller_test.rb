# frozen_string_literal: true

require "test_helper"

module Admin
  class ResultImportsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ResultSourceStubs

    setup { stub_result_sources }

    def import_params(event_id, races: { "u9-girls" => { import: "1", name: "U9 Girls", distance: "" } })
      { url: CONNAUGHT_XC_URL, event_id:, races: }
    end

    { "anonymous users" => nil, "logged in users who aren't admins" => :bugs }.each do |who, user|
      test "#{who} can't see or use the importer" do
        sign_in users(user) if user

        get new_admin_result_import_url

        assert_response :not_found

        get preview_admin_result_imports_url(url: CONNAUGHT_XC_URL)

        assert_response :not_found

        assert_no_difference -> { Result.count } do
          post admin_result_imports_url, params: import_params(events(:first).id)
        end
        assert_response :not_found
      end
    end

    test "admins can see the importer" do
      sign_in users(:admin)
      get new_admin_result_import_url

      assert_response :success
      assert_select "p", /Pop Up Races or Connaught Athletics/
    end

    test "prompts to create the event, filled in from the results page" do
      sign_in users(:admin)
      get preview_admin_result_imports_url(url: CONNAUGHT_XC_URL)

      assert_response :success
      assert_select "input[name=event_id][value=new][checked]"
      assert_select "input[name='event[title]'][value='Mayo XC Uneven Ages']"
      assert_select "input[name='event[start_time]'][value^='2026-10-11T00:00']"
      assert_select "input[name='event[content]'][value*='Swinford']"
      assert_select "input[name='races[u9-girls][import]'][checked]"
    end

    test "fills in the start time and distances when the page has them" do
      sign_in users(:admin)
      get preview_admin_result_imports_url(url: POP_UP_RACES_URL)

      assert_select "input[name='event[start_time]'][value^='2026-09-23T11:00']"
      assert_select "input[name='races[7336A4][distance]'][value='1000']"
      assert_select "input[name='races[6D8DA3][import]'][type=checkbox]:not([checked])"
    end

    test "suggests an existing event on the same day" do
      event = Event.create!(title: "Mayo Uneven Age XC", start_time: Time.zone.local(2026, 10, 11, 12))
      sign_in users(:admin)
      get preview_admin_result_imports_url(url: CONNAUGHT_XC_URL)

      assert_select "input[name=event_id][value='#{event.id}'][checked]"
      assert_select "input[name=event_id][value=new]:not([checked])"
    end

    test "sends you back if the website isn't supported" do
      sign_in users(:admin)
      get preview_admin_result_imports_url(url: "https://example.com/results")

      assert_redirected_to new_admin_result_import_url(url: "https://example.com/results")
      assert_match "Can't import results from example.com", flash[:alert]
    end

    test "creates the event and imports the results" do
      sign_in users(:admin)

      assert_difference -> { Event.count } => 1, -> { Result.count } => 2 do
        post admin_result_imports_url, params: import_params("new").merge(
          event: { title: "Mayo XC Uneven Ages", start_time: "2026-10-11T11:00", content: "<p>Swinford</p>" }
        )
      end

      event = Event.find_by(title: "Mayo XC Uneven Ages")

      assert_redirected_to admin_event_unlinked_results_url(event)
      assert_equal "Imported 2 results into Mayo XC Uneven Ages", flash[:notice]
      assert_equal ["U9 Girls"], event.races.map(&:name)
      assert_includes event.content.to_s, "Swinford"
    end

    test "imports into an existing event" do
      sign_in users(:admin)
      event = events(:first)

      assert_no_difference -> { Event.count } do
        post admin_result_imports_url, params: import_params(event.id)
      end

      assert_redirected_to admin_event_unlinked_results_url(event)
      assert_equal 2, event.races.find_by(name: "U9 Girls").results.count
    end

    test "doesn't import anything when no races are chosen" do
      sign_in users(:admin)

      assert_no_difference -> { Result.count } do
        post admin_result_imports_url,
             params: import_params(events(:first).id, races: { "u9-girls" => { import: "0" } })
      end

      assert_redirected_to preview_admin_result_imports_url(url: CONNAUGHT_XC_URL)
    end

    test "doesn't import anything when the new event is missing details" do
      sign_in users(:admin)

      assert_no_difference %w[Event.count Result.count] do
        post admin_result_imports_url, params: import_params("new").merge(event: { title: "", start_time: "" })
      end

      assert_redirected_to preview_admin_result_imports_url(url: CONNAUGHT_XC_URL)
    end
  end
end
