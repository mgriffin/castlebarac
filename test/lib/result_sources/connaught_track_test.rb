# frozen_string_literal: true

require "test_helper"

module ResultSources
  class ConnaughtTrackTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source(url = CONNAUGHT_TRACK_URL)
      ResultSources.for(url)
    end

    test "is used for Connaught Athletics track and field pages" do
      assert_kind_of ConnaughtTrack, source
      assert_kind_of ConnaughtTrack, source("https://connaughtathletics.com/2026/conninday3/")
    end

    test "reads the competition details" do
      assert_equal "Connacht Indoors 2026 Day 3 U9-U11", source.title
      assert_equal "TUS Arena", source.location
      assert_equal Date.new(2026, 4, 12), source.date
      assert_equal Time.zone.local(2026, 4, 12, 10, 0), source.start_time
    end

    test "lists the events, selecting the ones with results" do
      races = source.races

      assert_equal %w[777 779 790 799], races.map(&:key)
      assert_equal "U9 Boys 60m", races.first.name
      assert_equal [60, nil, nil, 600], races.map(&:distance)
      assert_equal [true, true, true, false], races.map(&:selected)
    end

    test "only selects the event in the link" do
      assert_equal %w[779], source("#{CONNAUGHT_TRACK_URL}?id=779").races.select(&:selected).map(&:key)
    end

    test "reads the results of the last round" do
      results = source.results_for("777")

      assert_equal([["1", "Sean BRUNTY", "10.37"], ["2", "Liam WALSH", "10.52"], [nil, "Tom BURKE", "DNS"]],
                   results.map { |r| [r.position, r.name, r.time] })
      assert_equal BigDecimal("10.37"), results.first.seconds
    end

    test "doesn't treat field event marks as times" do
      result = source.results_for("779").first

      assert_equal "3.18", result.time
      assert_nil result.seconds
    end

    test "uses the team name for relays" do
      assert_equal "Castlebar A.C. 4x200 Male Under 9 {A}", source.results_for("790").first.name
    end
  end
end
