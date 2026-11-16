# frozen_string_literal: true

require "test_helper"

class CompetitionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CompetitionEntriesFlag

  test "lists upcoming competitions that aren't drafts" do
    get competitions_url

    assert_response :success
    assert_select "h2 a", competitions(:connacht).name
    assert_select "h2 a", text: competitions(:county).name, count: 0
  end

  test "shows a competition" do
    get competition_url(competitions(:connacht))

    assert_response :success
    assert_select "p", /€5.00 per athlete for each event/
    assert_select "td", "U12 Girls 600m"
  end

  test "says when entries have closed" do
    get competition_url(competitions(:nationals))

    assert_select "p", "Entries are closed"
  end

  test "only the committee can see a draft competition" do
    get competition_url(competitions(:county))

    assert_response :not_found

    sign_in users(:secretary)
    get competition_url(competitions(:county))

    assert_response :success
  end

  test "links the committee to managing competitions" do
    get competitions_url
    assert_select "a[href=?]", admin_competitions_path, count: 0

    sign_in users(:secretary)
    get competitions_url
    assert_select "a[href=?]", admin_competitions_path
  end
end
