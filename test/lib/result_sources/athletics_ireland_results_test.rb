# frozen_string_literal: true

require "test_helper"

module ResultSources
  class AthleticsIrelandResultsTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source(url = ATHLETICS_IRELAND_URL)
      ResultSources.for(url)
    end

    test "reads the competition details" do
      assert_kind_of AthleticsIrelandResults, source
      assert_equal "National Juvenile Championships Day 1 and 2", source.title
      assert_equal "Tullamore", source.location
      assert_equal Date.new(2026, 6, 27), source.date
    end

    test "lists the events with their day and distance" do
      races = source.races

      assert_equal %w[3 14 73], races.map(&:key)
      assert_equal "Girls U19 400m Sprint – Sun 28 Jun", races.first.label
      assert_equal [400, nil, nil], races.map(&:distance)
      assert races.all?(&:selected)
    end

    test "only selects the events on the day in the link" do
      day_two = source("#{ATHLETICS_IRELAND_URL}?date=2026-06-28")

      assert_equal Date.new(2026, 6, 28), day_two.date
      assert_equal %w[3 73], day_two.races.select(&:selected).map(&:key)
    end

    test "reads the final's results in order" do
      results = source.results_for("3")

      assert_equal([["1", "Erin FRIEL", "54.92"], ["2", "Sofia GRANJO", "55.60"], ["3", "Aoife NIC SUIBHNE", "57.14"]],
                   results.map { |r| [r.position, r.name, r.time] })
      assert_equal "Castlebar A.C.", results.last.club
      assert_equal BigDecimal("54.92"), results.first.seconds
    end

    test "doesn't treat field event marks as times" do
      result = source.results_for("14").first

      assert_equal ["Méabh O'CONNELL", "38.11"], [result.name, result.time]
      assert_nil result.seconds
    end

    test "uses the team name for relays" do
      result = source.results_for("73").first

      assert_equal ["Clonliffe Harriers A.C.", "Clonliffe Harriers A.C."], [result.name, result.club]
    end
  end
end
