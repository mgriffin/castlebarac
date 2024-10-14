# frozen_string_literal: true

require "test_helper"

class ListEventsComponentTest < ViewComponent::TestCase
  def test_static_string_shown_when_there_are_no_events
    render_inline(ListEventsComponent.new)

    assert_text "There are no events coming up"
  end

  def test_list_of_events_shown_when_they_exist
    e = events(:first)

    render_inline(ListEventsComponent.new) do |c|
      c.with_events([e])
    end

    refute_text "There are no events coming up"
    assert_selector("p", text: e.title)
  end
end
