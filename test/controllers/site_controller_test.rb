# frozen_string_literal: true

require "test_helper"

class SiteControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "shows competitions that are taking entries" do
    Flipper.enable("comp-entries")

    get root_url

    assert_equal([competitions(:connacht).name], css_select(".competition-card h2").map { it.text.strip })
    assert_select ".competition-card a[href=?]", competition_entry_path(competitions(:connacht)), "Enter athletes"
  end

  test "doesn't show a competition once its entries close" do
    Flipper.enable("comp-entries")
    competitions(:connacht).update!(entries_close_at: 1.minute.ago)

    get root_url

    assert_select ".competition-card", count: 0
  end
end
