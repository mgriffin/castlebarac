# frozen_string_literal: true

require "test_helper"

class ResultTest < ActiveSupport::TestCase
  test "returns seconds with decimals" do
    result = Result.new(seconds: 45.63)
    assert_equal "45.63", result.net_time
  end

  test "returns seconds" do
    result = Result.new(seconds: 45)
    assert_equal "45.0", result.net_time
  end

  test "returns minutes" do
    result = Result.new(seconds: 105)
    assert_equal "1:45.0", result.net_time
  end

  test "returns proper" do
    result = Result.new(seconds: 136.82)
    assert_equal "2:16.82", result.net_time
  end

  test "zero pads seconds" do
    result = Result.new(seconds: 69.06)
    assert_equal "1:09.06", result.net_time
  end

  test "shows two decimal places" do
    result = Result.new(seconds: 69.059999999)
    assert_equal "1:09.05", result.net_time
  end
end
