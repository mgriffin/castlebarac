# frozen_string_literal: true

require "test_helper"

class ListPostsComponentTest < ViewComponent::TestCase
  def test_static_string_shown_when_there_are_no_posts
    render_inline(ListPostsComponent.new)

    assert_text "There's no news"
  end

  def test_list_of_posts_shown_when_they_exist
    p = posts(:one)

    render_inline(ListPostsComponent.new) do |c|
      c.with_posts([p])
    end

    refute_text "There's no news"
    assert_selector("h2", text: p.title)
  end
end
