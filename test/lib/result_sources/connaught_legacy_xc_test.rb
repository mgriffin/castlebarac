# frozen_string_literal: true

require "test_helper"

module ResultSources
  class ConnaughtLegacyXcTest < ActiveSupport::TestCase
    include ResultSourceStubs

    setup { stub_result_sources }

    def source
      ResultSources.for(CONNAUGHT_LEGACY_XC_URL)
    end

    test "is used for the older Connaught Athletics cross country pages" do
      assert_kind_of ConnaughtLegacyXc, source
    end

    test "reads the title but there's no date" do
      assert_equal "Connacht Even Age Cross Country 2025", source.title
      assert_nil source.date
    end

    test "lists a race for each button" do
      races = source.races

      assert_equal "U10G.html", races.first.key
      assert_not_includes races.map(&:key), "entries.html"
      assert races.all?(&:selected)
    end

    test "reads the individual results" do
      results = source.results_for("U10G.html")

      assert_equal ["1", "Katie Considine", "Craughwell A.C.", "Galway"],
                   results.first.to_h.values_at(:position, :name, :club, :county)
      assert_equal 72, results.size
    end
  end
end
