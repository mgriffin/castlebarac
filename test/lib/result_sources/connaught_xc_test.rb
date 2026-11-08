# frozen_string_literal: true

require "test_helper"

module ResultSources
  class ConnaughtXcTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source(url = CONNAUGHT_XC_URL)
      ResultSources.for(url)
    end

    test "reads the event details" do
      assert_equal "Mayo XC Uneven Ages", source.title
      assert_equal Date.new(2026, 10, 11), source.date
      assert_equal "Swinford", source.location
      assert_not source.start_time_known?
      assert_includes source.event_content, "Swinford"
      assert_includes source.event_content, %(href="#{CONNAUGHT_XC_URL}")
    end

    test "lists the races" do
      assert_equal([["u9-girls", "U9 Girls"], ["u9-boys", "U9 Boys"]], source.races.map { |r| [r.key, r.name] })
      assert source.races.all?(&:selected)
    end

    test "only selects the race in the link" do
      assert_equal [false, true], source("#{CONNAUGHT_XC_URL}/u9-boys").races.map(&:selected)
    end

    test "reads individual results but not team results" do
      results = source.results_for("u9-girls")

      assert_equal ["1", "Chloe McDonnell", "East Mayo AC", "388", nil],
                   results.first.to_h.values_at(:position, :name, :club, :bib, :time)
      assert_equal ["Chloe McDonnell", "Lucy O'Keeffe"], results.map(&:name)
    end

    test "reads counties separately from clubs" do
      results = source(CONNAUGHT_XC_REGIONAL_URL).results_for("u9-boys")

      assert_equal([["North Sligo AC", "Sligo"], ["Castlebar AC", "Mayo"]], results.map { |r| [r.club, r.county] })
      assert_nil source.results_for("u9-girls").first.county
    end

    test "only reads cross country results pages" do
      assert_raises(ResultSources::Error) { source("https://connaughtathletics.com/something-else") }
    end
  end
end
