# frozen_string_literal: true

require "test_helper"

class AdminToolbarComponentTest < ViewComponent::TestCase
  def test_is_not_shown_when_no_user
    render_inline(AdminToolbarComponent.new(user: nil))

    refute_component_rendered
  end

  def test_is_not_shown_when_user_is_not_admin
    user = users(:bugs)
    render_inline(AdminToolbarComponent.new(user:))

    refute_component_rendered
  end

  def test_is_shown_when_user_is_admin
    user = users(:admin)
    render_inline(AdminToolbarComponent.new(user:))

    assert_component_rendered
    assert_selector("a", text: "Admin")
  end
end
