# frozen_string_literal: true

require "test_helper"

# Pages for a post, event or person that doesn't exist should say so with a
# 404, not fail with a 500. Signed in as an admin, so it's the missing record
# that's tested and not the permissions.
class NotFoundTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:admin) }

  test "pages for something that doesn't exist are not found" do
    [edit_event_path("missing"), person_path("missing"),
     admin_event_path("missing"), edit_admin_event_path("missing"),
     edit_admin_post_path("missing"),
     edit_admin_person_path("missing")].each do |page|
      get page
      assert_response :not_found, page
    end
  end

  test "changing something that doesn't exist is not found" do
    patch event_path("missing"), params: { event: { title: "Renamed" } }
    assert_response :not_found

    patch admin_event_path("missing"), params: { event: { title: "Renamed" } }
    assert_response :not_found

    patch admin_post_path("missing"), params: { post: { title: "Renamed" } }
    assert_response :not_found

    patch admin_person_path("missing"), params: { person: { firstname: "Bugsy" } }
    assert_response :not_found

    post post_comments_path("missing"), params: { comment: { body: "Well done" } }
    assert_response :not_found
  end
end
