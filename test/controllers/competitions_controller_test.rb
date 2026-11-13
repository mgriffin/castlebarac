# frozen_string_literal: true

require "test_helper"

class CompetitionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "lists upcoming competitions that aren't drafts" do
    get competitions_url

    assert_response :success
    assert_select "h2 a", competitions(:connacht).name
    assert_select "h2 a", text: competitions(:county).name, count: 0
  end

  test "shows a competition with a link to enter" do
    get competition_url(competitions(:connacht))

    assert_response :success
    assert_select "a[href='#{competition_entry_path(competitions(:connacht))}']", "Enter athletes"
    assert_select "td", "U12 Girls 600m"
  end

  test "doesn't link to enter once entries close" do
    get competition_url(competitions(:nationals))

    assert_select "p", "Entries are closed"
    assert_select "a", text: "Enter athletes", count: 0
  end

  test "only the committee can see a draft competition" do
    get competition_url(competitions(:county))

    assert_response :not_found

    sign_in users(:secretary)
    get competition_url(competitions(:county))

    assert_response :success
  end
end
