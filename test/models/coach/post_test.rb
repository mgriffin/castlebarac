# frozen_string_literal: true

require "test_helper"

module Coach
  class PostTest < ActiveSupport::TestCase
    test "Coach::Post gets a slug when created" do
      user = users(:coach)

      result = travel_to Date.new(2004, 11, 24) do
        Coach::Post.create!(title: "new post", user:)
      end

      assert_equal "2004-11-24-new-post", result.slug
    end
  end
end
