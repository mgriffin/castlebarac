# frozen_string_literal: true

require "test_helper"

module ResultSources
  class PopUpRacesTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source(url = POP_UP_RACES_URL)
      ResultSources.for(url)
    end

    test "reads the event details" do
      assert_equal "Mayo Primary Schools XC 2026", source.title
      assert_equal Date.new(2026, 9, 23), source.date
      assert_equal Time.zone.local(2026, 9, 23, 11, 0), source.start_time
      assert_predicate source, :start_time_known?
    end

    test "lists the individual results with their distances" do
      races = source.races

      assert_equal %w[7336A4 9D70EA 6D8DA3], races.map(&:key)
      assert_equal "3rd & 4th Class Girls", races.first.name
      assert_equal "3rd & 4th Class Girls – Full Results", races.first.label
      assert_equal 1000, races.first.distance
      assert_equal [true, true, false], races.map(&:selected)
    end

    test "only selects the race in the link" do
      assert_equal [true, false, false], source("#{POP_UP_RACES_URL}#1_7336A4").races.map(&:selected)
    end

    test "reads results" do
      results = source.results_for("7336A4")

      assert_equal 3, results.size
      assert_equal ["1", "Juliette NIC SUIBHNE", "Raifteirí", "344", "0:03:59"],
                   results.first.to_h.values_at(:position, :name, :club, :bib, :time)
      assert_nil results.last.position_number
    end

    test "converts distances to metres" do
      assert_equal 1200, PopUpRaces.distance_in_metres("1200m")
      assert_equal 5000, PopUpRaces.distance_in_metres("5km")
      assert_equal 1609, PopUpRaces.distance_in_metres("1 mile")
      assert_nil PopUpRaces.distance_in_metres("3rd & 4th Class Girls")
    end

    test "copes with a page without a date or results" do
      stub_request(:get, POP_UP_RACES_URL).to_return(body: "<h1 class='page-title'>A race</h1>")

      assert_nil source.date
      assert_nil source.start_time
      assert_raises(ResultSources::Error) { source.races }
    end
  end
end
