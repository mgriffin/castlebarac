# frozen_string_literal: true

require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an event's results only look up the user's teams once" do
    30.times do |i|
      Result.create!(race: races(:one), name: "Runner #{i}", club: "Castlebar A.C.", person: people(:snori))
    end
    sign_in users(:admin)

    assert_queries_match(/FROM "teams"/, count: 1) do
      get event_path(events(:first))
    end

    assert_response :success
    assert_select "a[href^='/admin/results/']", 30
  end
end
