# frozen_string_literal: true

require "test_helper"

# Every action has to check permissions (ApplicationController's
# verify_authorized), or Pundit raises. This opens every page and uses the
# forms that other tests don't, so one that forgets fails here instead of for
# visitors. Add new pages to these lists.
class AuthorizationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @event = events(:first)
    @time_trial = TimeTrial.create!(recorded_at: Date.current, distance: 1000)
    @result = Result.create!(race: races(:one), name: "Bugs Bunny")
  end

  def public_pages
    [root_path, events_path, event_path(@event), rss_path, training_times_path, training_little_athletics_path]
  end

  def staff_pages
    [new_event_path, edit_event_path(@event), new_time_trial_path, time_trial_path(@time_trial),
     new_time_trial_tt_time_path(@time_trial)]
  end

  def admin_pages
    [admin_root_path, admin_events_path, admin_event_path(@event), edit_admin_event_path(@event),
     admin_posts_path, edit_admin_post_path(posts(:one)),
     new_admin_person_path, edit_admin_result_path(@result), admin_teams_path, new_admin_team_path,
     admin_user_path(users(:bugs))]
  end

  test "admins can open every page" do
    sign_in users(:admin)

    (public_pages + staff_pages + admin_pages).each do |page|
      get page
      assert_response :success, page
    end
  end

  test "admins can use the forms" do
    sign_in users(:admin)

    post events_path, params: { event: { title: "Race day", start_time: 1.week.from_now } }
    assert_response :redirect

    patch event_path(@event), params: { event: { title: "Renamed" } }
    assert_response :redirect

    post admin_people_path, params: { person: { firstname: "New", surname: "Person" } }
    assert_response :redirect

    patch admin_person_path(people(:bugsbunny)), params: { person: { firstname: "Bugsy", surname: "Bunny" } }
    assert_response :see_other

    post admin_teams_path, params: { team: { name: "Volunteers" } }
    assert_response :redirect

    patch time_trial_path(@time_trial), params: { time_trial: { distance: 2000 } }
    assert_response :redirect

    post post_comments_path(posts(:one)), params: { comment: { body: "Well done" } }
    assert_response :redirect
  end

  test "admins can impersonate someone and stop" do
    sign_in users(:admin)

    post impersonate_admin_user_path(users(:bugs))
    assert_redirected_to root_path

    delete impersonation_path
    assert_redirected_to root_path
  end

  test "anonymous visitors can open public pages" do
    public_pages.each do |page|
      get page
      assert_response :success, page
    end
  end

  test "anonymous visitors can't open staff or admin pages" do
    (staff_pages + admin_pages).each do |page|
      get page
      assert_response :not_found, page
    end
  end
end
