# frozen_string_literal: true

require "active_support/testing/assertions"
require "minitest/autorun"
require "webmock/minitest"

require "test_helper"

class TestResults < ActiveSupport::TestCase
  def test_can_get_name_of_competition
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens.html"))

    url = "https://connaughtathletics.com/2025/connacht/XC/evens/"
    competition = ConnaughtAthletics::Competition.new(url:)

    assert_equal "Connacht Even Age Cross Country 2025", competition.name
    assert_equal "connacht-even-age-cross-country-2025", competition.slug
  end

  def test_can_get_events_from_competition_url
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens.html"))

    url = "https://connaughtathletics.com/2025/connacht/XC/evens/"
    competition = ConnaughtAthletics::Competition.new(url:)
    events = competition.events

    assert_equal events.count, 15
    assert_kind_of ConnaughtAthletics::Event, events.first
  end

  def test_can_get_results_from_event_url
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens.html"))
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/U10G.html")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens-u10g.html"))

    url = "https://connaughtathletics.com/2025/connacht/XC/evens/"
    competition = ConnaughtAthletics::Competition.new(url:)
    event = competition.event(name: "U10G", url: "U10G.html")

    results = event.results
    assert_equal results.count, 72
    assert_kind_of ConnaughtAthletics::Result, results.first
  end

  def test_can_output_to_csv
    only_one_event = <<~EVENT
      <div class="button-container">
        <h5><i class="fas fa-running"></i> Select Age Category</h5>
        <button onclick="loadPage('U10G.html')">U10G</button>
    EVENT

    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/")
      .to_return(status: 200, body: only_one_event)
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/U10G.html")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens-u10g.html"))

    url = "https://connaughtathletics.com/2025/connacht/XC/evens/"
    competition = ConnaughtAthletics::Competition.new(url:)

    result = competition.to_csv
    assert_equal "Place,Name,Club,County", result.split.first
  end

  def test_can_save_results_to_db
    only_one_event = <<~EVENT
      <title>Connacht Even Age Cross Country 2025</title>
        <div class="button-container">
          <h5><i class="fas fa-running"></i> Select Age Category</h5>
          <button onclick="loadPage('U10G.html')">U10G</button>
    EVENT

    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/")
      .to_return(status: 200, body: only_one_event)
    stub_request(:get, "https://connaughtathletics.com/2025/connacht/XC/evens/U10G.html")
      .to_return(status: 200, body: File.open("test/fixtures/files/2025-connacht-xc-evens-u10g.html"))

    url = "https://connaughtathletics.com/2025/connacht/XC/evens/"
    competition = ConnaughtAthletics::Competition.new(url:)

    assert_difference -> { Event.count } => 1, -> { Race.count } => 1, -> { Result.count } => 72 do
      competition.save_results
    end
  end
end
