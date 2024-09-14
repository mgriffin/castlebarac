# frozen_string_literal: true

require "test_helper"

class HeadingComponentTest < ViewComponent::TestCase
  def test_component_renders_a_h2_heading_by_default
    assert_equal(
      %(<h2>Hello, components!</h2>),
      render_inline(HeadingComponent.new(tag: :narf).with_content("Hello, components!")).css("h2").to_html
    )
  end

  def test_component_renders_a_h1_heading
    assert_equal(
      %(<h1>Hello, components!</h1>),
      render_inline(HeadingComponent.new(tag: :h1).with_content("Hello, components!")).css("h1").to_html
    )
  end
end
