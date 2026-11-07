# frozen_string_literal: true

require "test_helper"

class ResultImportTest < ActiveSupport::TestCase
  include ResultSourceStubs

  setup do
    stub_result_sources
    @event = events(:first)
  end

  def import(url, key, name: "Race", distance: nil)
    selection = ResultImport::Selection.new(key:, name:, distance:)
    ResultImport.new(source: ResultSources.for(url), event: @event, selections: [selection]).call
  end

  test "saves timed results" do
    assert_difference -> { @event.races.count } => 1, -> { Result.count } => 3 do
      assert_equal 3, import(POP_UP_RACES_URL, "7336A4", name: "Girls", distance: 1000)
    end

    result = @event.races.find_by(name: "Girls").results.find_by(bib: 344)

    assert_equal ["Juliette NIC SUIBHNE", "Raifteirí", 1, 239, "0:03:59", 1000],
                 [result.name, result.club, result.position, result.seconds, result.result, result.distance]
    assert_equal "DNF", Result.find_by(bib: 60).net_time
  end

  test "saves untimed results and recognises our club" do
    import(CONNAUGHT_XC_URL, "u9-girls")

    result = Result.find_by(name: "Lucy O'Keeffe")

    assert_equal "Castlebar A.C.", result.club
    assert_predicate result, :castlebarac?
    assert_nil result.seconds
  end

  test "importing again updates results instead of adding them twice" do
    import(CONNAUGHT_XC_URL, "u9-girls")
    result = Result.find_by(bib: 388)
    result.update!(position: 99, person: people(:snori))

    assert_no_difference -> { Result.count } do
      import(CONNAUGHT_XC_URL, "u9-girls")
    end

    assert_equal 1, result.reload.position
    assert_equal people(:snori), result.person
  end
end
