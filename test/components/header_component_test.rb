# frozen_string_literal: true

require "test_helper"

class HeaderComponentTest < ViewComponent::TestCase
  def test_header_renders_home_link
    render_inline(HeaderComponent.new(user_signed_in: false))

    assert_selector("a", text: "Castlebar A.C.")
  end

  def test_header_renders_about_link
    render_inline(HeaderComponent.new(user_signed_in: false))

    assert_selector("a", text: "About")
  end

  def test_header_does_not_render_log_in_link_when_feature_flag_is_disabled
    render_inline(HeaderComponent.new(user_signed_in: false))

    refute_selector("a", text: "Log in")
  end

  def test_header_renders_log_in_link_when_logged_out
    Flipper.enable :login

    render_inline(HeaderComponent.new(user_signed_in: false))

    assert_selector("a", text: "Log in")
    refute_selector("a", text: "Log out")
  end

  def test_header_renders_log_out_link_when_logged_in
    Flipper.enable :login

    render_inline(HeaderComponent.new(user_signed_in: true))

    assert_selector("a", text: "Log out")
    refute_selector("a", text: "Log in")
  end
end
