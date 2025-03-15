# frozen_string_literal: true

require "test_helper"

class AddResultsToEventJobTest < ActiveJob::TestCase
  test "can add results to an event given the results URL" do
    competition_body =<<~BODY
    <table class="schedule-table"><thead><tr><th class="event-column align-left">EVENT</th><th class="participants-column">ENTRIES</th><th class="status-column">STATUS</th></tr></thead><tbody><tr onclick="window.location='results.php?id=397'" style="cursor: pointer;" class="completed-event"><td>ACME 60m</td><td class="participants-column">95</td><td class="status-column">Official</td></tr></tbody></table>
    BODY

    results_body =<<~BODY
    <title>ACME 60m - Results</title>
<script>
const roundData = { "1": { "name": "*", "heats": { "1": [ { "name": "Road RUNNER", "club": "GoodGuys A.C.", "result": "8.71", "sortValue": 8.71, "result_value": "8.706", "currentOrder": 1, "initialorder": 2, "heatNumber": 1, "bib": "79", "category": "ACME", "categoryAbbr": "A", "info": "-", "displayPosition": 1, "pb": "" }, { "name": "Wile E COYOTE", "club": "BadGuys A.C.", "result": "8.75", "sortValue": 8.75, "result_value": "8.743", "currentOrder": 1, "initialorder": 7, "heatNumber": 1, "bib": "107", "category": "ACME", "categoryAbbr": "A", "info": "-", "displayPosition": 2, "pb": "" } ] }, "allParticipants": [ { "name": "Road RUNNER", "club": "GoodGuys A.C.", "result": "8.71", "sortValue": 8.71, "result_value": "8.706", "currentOrder": 1, "initialorder": 1, "heatNumber": 1, "bib": "79", "category": "ACME", "categoryAbbr": "A", "info": "-", "displayPosition": 1, "pb": "" }, { "name": "Wile E COYOTE", "club": "BadGuys A.C.", "result": "8.75", "sortValue": 8.75, "result_value": "8.743", "currentOrder": 1, "initialorder": 7, "heatNumber": 1, "bib": "107", "category": "ACME", "categoryAbbr": "A", "info": "-", "displayPosition": 2, "pb": "" } ], "info": " ", "scheduled": "00:00:00", "status": "5", "datescheduled": "2025-02-15", "unassignedParticipants": [] } } ;
const isRelayEvent = false;

function showHeat(heatId) {
}
</script>
    BODY

    stub_request(:get, "https://example.com/race/competition.php").to_return(status: 200, body: competition_body )
    stub_request(:get, "https://example.com/race/results.php?id=397").to_return(status: 200, body: results_body)

    event = events(:first)

    assert_difference -> { Race.count } => 1, -> { Result.count } => 2 do
      AddResultsToEventJob.perform_now(event: event, url: "https://example.com/race")
    end

    race = Race.find_by(name: "ACME 60m")
    assert_equal "Road RUNNER", race.results.first.name
  end

  test "relays" do
    competition_body =<<~BODY
    <table class="schedule-table"><thead><tr><th class="event-column align-left">EVENT</th><th class="participants-column">ENTRIES</th><th class="status-column">STATUS</th></tr></thead><tbody><tr onclick="window.location='results.php?id=397'" style="cursor: pointer;" class="completed-event"><td>ACME Relay - Results</td><td class="participants-column">95</td><td class="status-column">Official</td></tr></tbody></table>
    BODY

    results_body =<<~BODY
    <title>ACME Relay - Results</title>
    <script>
const roundData = { "1": { "name": "*", "heats": { "1": [ { "isRelay": true, "teamName": "Bubbles A.C. 4 x 200 Male Under 12", "club": "Bubbles A.C.", "result": "2:11.70", "sortValue": 131.7, "result_value": "131.693", "currentOrder": 1, "initialorder": 1, "info": "-", "runners": [ { "name": "I P FREELY", "bib": "703" }, { "name": "John DOE", "bib": "703" }, { "name": "Ariel FARTWORTH", "bib": "703" }, { "name": "Róise MCSPEEDY", "bib": "703" }, { "name": "Sadhbh WITCHTOES", "bib": "703" } ], "displayPosition": 1, "pb": "", "category": { "name": "U12 Boys", "abbreviation": "U12B" }, "heatNumber": 1 }, { "isRelay": true, "teamName": "ACME A.C. 4 x 200 Male Under 12", "club": "ACME A.C.", "result": "2:12.92", "sortValue": 132.92, "result_value": "132.92", "currentOrder": 2, "initialorder": 3, "info": "-", "runners": [ { "name": "Bugs BUNNY", "bib": "771" }, { "name": "Road RUNNER", "bib": "771" }, { "name": "Foghorn LEGHORN", "bib": "771" }, { "name": "Speedy GONZALEZ", "bib": "771" }, { "name": "Daffy DUCK", "bib": "771" } ], "displayPosition": 2, "pb": "", "category": { "name": "U12 Boys", "abbreviation": "U12B" }, "heatNumber": 1 } ] }, "allParticipants": [ { "isRelay": true, "teamName": "Bubbles A.C. 4 x 200 Male Under 12", "club": "Bubbles A.C.", "result": "2:11.70", "sortValue": 131.7, "result_value": "131.693", "currentOrder": 1, "initialorder": 1, "info": "-", "runners": [ { "name": "I P FREELY", "bib": "703" }, { "name": "John DOE", "bib": "703" }, { "name": "Ariel FARTWORTH", "bib": "703" }, { "name": "Róise MCSPEEDY", "bib": "703" }, { "name": "Sadhbh WITCHTOES", "bib": "703" } ], "displayPosition": 1, "pb": "", "category": { "name": "U12 Boys", "abbreviation": "U12B" }, "heatNumber": 1 }, { "isRelay": true, "teamName": "ACME A.C. 4 x 200 Male Under 12", "club": "ACME A.C.", "result": "2:12.92", "sortValue": 132.92, "result_value": "132.92", "currentOrder": 2, "initialorder": 3, "info": "-", "runners": [ { "name": "Bugs BUNNY", "bib": "771" }, { "name": "Road RUNNER", "bib": "771" }, { "name": "Foghorn LEGHORN", "bib": "771" }, { "name": "Speedy GONZALEZ", "bib": "771" }, { "name": "Daffy DUCK", "bib": "771" } ], "displayPosition": 2, "pb": "", "category": { "name": "U12 Boys", "abbreviation": "U12B" }, "heatNumber": 1 } ], "info": "", "scheduled": "12:00:00", "status": "5", "datescheduled": "2025-02-15", "unassignedParticipants": [] } } ;
const isRelayEvent = true;

function showHeat(heatId) {
}
</script>
    BODY

    stub_request(:get, "https://example.com/race/competition.php").to_return(status: 200, body: competition_body )
    stub_request(:get, "https://example.com/race/results.php?id=397").to_return(status: 200, body: results_body)

    event = events(:first)

    assert_difference -> { Race.count } => 1, -> { Result.count } => 2 do
      AddResultsToEventJob.perform_now(event: event, url: "https://example.com/race")
    end

    race = Race.find_by(name: "ACME Relay")
    assert_equal "Bubbles A.C. 4 x 200 Male Under 12", race.results.first.name
  end
end
