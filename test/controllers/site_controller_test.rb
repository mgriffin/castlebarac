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

  test "lists upcoming events with their dates" do
    event = Event.create!(title: "Connacht Juvenile Cross Country", start_time: Time.zone.local(2099, 11, 23, 11))

    get root_url

    assert_select ".upcoming-events a.upcoming-event[href=?]", event_path(event) do
      assert_select ".date-tile__month", "Nov"
      assert_select ".date-tile__day", "23"
      assert_select ".upcoming-event__title", "Connacht Juvenile Cross Country"
      assert_select ".upcoming-event__when", "Monday, 11:00am"
    end
  end

  test "says when there are no upcoming events" do
    get root_url

    assert_select ".upcoming-events", count: 0
    assert_select "p", "There are no events coming up"
  end
end
