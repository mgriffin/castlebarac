# frozen_string_literal: true

require "test_helper"

class ResultSourcesTest < ActiveSupport::TestCase
  test "picks the reader for the website" do
    assert_kind_of ResultSources::PopUpRaces, ResultSources.for("https://www.popupraces.ie/race/a-race/")
    assert_kind_of ResultSources::ConnaughtXc, ResultSources.for("https://connaughtathletics.com/XC/a-race")
    assert_kind_of ResultSources::MyRunResults, ResultSources.for("https://myrunresults.com/events/a-race/1/results")
    assert_kind_of ResultSources::AthleticsIrelandResults,
                   ResultSources.for("http://results.athleticsireland.ie/results_2026/a_meet/menu.html")
  end

  test "says which websites it can read" do
    error = assert_raises(ResultSources::Error) { ResultSources.for("https://example.com/results") }

    assert_equal "Can't import results from example.com yet. " \
                 "Try Pop Up Races, Connaught Athletics, Athletics Ireland, or MyRunResults.", error.message
  end

  test "needs a web address" do
    assert_raises(ResultSources::Error) { ResultSources.for("not a url") }
    assert_raises(ResultSources::Error) { ResultSources.for("") }
  end

  test "reads times" do
    row = ResultSources::Row.new(time: "0:03:59", position: "1", bib: "344")

    assert_equal 239, row.seconds
    assert_equal 1, row.position_number
    assert_equal 344, row.bib_number
    assert_nil ResultSources::Row.new(time: "DNF").seconds
    assert_nil ResultSources::Row.new(time: nil).seconds
  end
end
