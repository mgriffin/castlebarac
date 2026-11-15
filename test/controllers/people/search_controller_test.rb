# frozen_string_literal: true

require "test_helper"

module People
  class SearchControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def search(query)
      get people_search_index_url, params: { q: query }
    end

    def suggested_ids
      css_select("li[data-autocomplete-value]").map { it["data-autocomplete-value"].to_i }
    end

    test "anonymous visitors can't search for people" do
      search("Bu")

      assert_response :not_found
      assert_empty suggested_ids
    end

    test "users who aren't staff can't search for people" do
      sign_in users(:bugs)

      search("Bu")

      assert_response :not_found
      assert_empty suggested_ids
    end

    test "staff can search by the start of a first name or surname, ignoring case" do
      make_committee_member(users(:bugs))

      [users(:admin), users(:coach), users(:bugs)].each do |user|
        sign_in user

        search("bun")
        assert_response :success
        assert_equal [people(:bugsbunny).id], suggested_ids

        search("BUGS")
        assert_equal [people(:bugsbunny).id], suggested_ids

        sign_out user
      end
    end

    test "searches need at least two letters" do
      sign_in users(:admin)

      ["", " ", "B"].each do |query|
        search(query)

        assert_response :success
        assert_empty suggested_ids
        assert_select "li[aria-disabled]", "Type at least 2 letters"
      end
    end

    test "wildcards in a search are matched literally" do
      sign_in users(:admin)

      ["%%", "__", "_u"].each do |query|
        search(query)

        assert_empty suggested_ids
        assert_select "li[aria-disabled]", "No results"
      end
    end

    test "only the first 20 matches are listed, sorted by name" do
      25.times { |i| Person.create!(firstname: "Zed", surname: format("Zulu%02d", i)) }
      sign_in users(:admin)

      search("Zulu")

      assert_equal 20, suggested_ids.size
      assert_select "li[data-autocomplete-value]:first-child", "Zed Zulu00"
    end
  end
end
