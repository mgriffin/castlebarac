# frozen_string_literal: true

require "test_helper"

class PersonPolicyTest < ActiveSupport::TestCase
  test "private details are for the person, their parents and staff" do
    assert PersonPolicy.new(users(:bugs), people(:bugsbunny)).private_details?
    assert PersonPolicy.new(users(:bugs), people(:ciara)).private_details?
    assert PersonPolicy.new(users(:coach), people(:ciara)).private_details?

    assert_not PersonPolicy.new(users(:gabby), people(:ciara)).private_details?
    assert_not PersonPolicy.new(nil, people(:ciara)).private_details?
  end
end
