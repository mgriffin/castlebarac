# frozen_string_literal: true

require "test_helper"

class ResultsHelperTest < ActionView::TestCase
  test "returns seconds with decimals" do
    assert_equal "45.63", net_time(45.63)
  end

  test "returns seconds" do
    assert_equal "45", net_time(45)
  end

  test "returns minutes" do
    assert_equal "1:45", net_time(105)
  end

  test "returns proper" do
    assert_equal "2:16.82", net_time(136.82)
  end

  test "zero pads seconds" do
    assert_equal "1:09.06", net_time(69.06)
  end

  test "shows two decimal places" do
    assert_equal "1:09.05", net_time(69.059999999)
  end
end
