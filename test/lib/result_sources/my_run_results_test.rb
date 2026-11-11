# frozen_string_literal: true

require "test_helper"

module ResultSources
  class MyRunResultsTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source
      ResultSources.for(MY_RUN_RESULTS_URL)
    end

    test "reads the event details" do
      assert_kind_of MyRunResults, source
      assert_equal "123.ie National Uneven XC 2025", source.title
      assert_equal Time.zone.local(2025, 12, 7, 10, 0), source.start_time
      assert_predicate source, :start_time_known?
    end

    test "lists a race for each class" do
      assert_equal ["Girls U11", "Boys U11"], source.races.map(&:key)
    end

    test "reads the results" do
      results = source.results_for("Girls U11")

      assert_equal ["1", "Sadhbh CALLAN", "Foyle Valley A.C.", "656", "00:05:45"],
                   results.first.to_h.values_at(:position, :name, :club, :bib, :time)
      assert_equal 345, results.first.seconds
      assert_equal [nil, "DNF"], [results.last.position, results.last.time]
    end

    test "only reads event pages" do
      assert_raises(ResultSources::Error) { ResultSources.for("https://myrunresults.com/race-results") }
    end
  end
end
