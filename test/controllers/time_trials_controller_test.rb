# frozen_string_literal: true

require "test_helper"

class TimeTrialsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "anonymous user can't load time trials page" do
    get time_trials_url

    assert_response :not_found
  end

  test "logged in user can't load time trials page" do
    sign_in users(:bugs)

    get time_trials_url

    assert_response :not_found
  end

  test "logged in coach can load time trials page" do
    sign_in users(:coach)

    get time_trials_url

    assert_response :success
  end

  test "logged in coach can create a new time trial" do
    bugsbunny = people(:bugsbunny)
    sign_in users(:coach)

    assert_difference "TimeTrial.count" do
      post time_trials_url,
           params: {
             "time_trial" => {
               "recorded_at" => "2024-01-01",
               "distance" => "800m",
               "surface" => "Gravel Track",
               "tt_times_attributes" => {
                 "123" => {
                   "person_id" => bugsbunny.id,
                   "seconds" => "300"
                 }
               }
             }
           }
    end

    assert_redirected_to time_trial_path(TimeTrial.last)
  end
end
