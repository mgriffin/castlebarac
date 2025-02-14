# frozen_string_literal: true

require "test_helper"

class AddResultsToEventJobTest < ActiveJob::TestCase
  test "the truth" do
    json = <<~JSON
      [
        {
          "name": "ACME Dash - Results",
          "participants": [
            {
              "name": "Road Runner",
              "club": "ACME AC",
              "result": "4:33.97",
              "sortValue": 273.97,
              "currentOrder": 1,
              "initialorder": 1,
              "heatNumber": 1,
              "bib": "467",
              "category": "RoadRunner",
              "categoryAbbr": "RR",
              "info": "-",
              "displayPosition": 1
            },
            {
              "name": "Wile E. Coyote",
              "club": "ACME AC",
              "result": "4:50.04",
              "sortValue": 290.04,
              "currentOrder": 2,
              "initialorder": 4,
              "heatNumber": 1,
              "bib": "466",
              "category": "RoadRunner",
              "categoryAbbr": "RR",
              "info": "-",
              "displayPosition": 2
            }
          ]
        }
      ]
    JSON

    event = events(:first)

    assert_difference -> { Race.count } => 1, -> { Result.count } => 2 do
      AddResultsToEventJob.perform_now(event_id: event.id, races: JSON.parse(json))
    end
  end
end
