# frozen_string_literal: true

require "test_helper"

class ResultImportLinkingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ResultSourceStubs

  setup do
    stub_result_sources
    sign_in users(:admin)
    @event = events(:first)
  end

  def import
    post admin_result_imports_url, params: {
      url: CONNAUGHT_XC_URL, event_id: @event.id, races: { "u9-girls" => { import: "1", name: "U9 Girls" } }
    }
  end

  test "links Castlebar athletes who are already on the site" do
    lucy = Person.create!(firstname: "Lucy", surname: "O'Keeffe")

    import

    assert_redirected_to event_url(@event)
    assert_equal "Imported 2 results into #{@event.title} and linked 1 Castlebar athlete to their profile",
                 flash[:notice]
    assert_equal lucy, Result.find_by(name: "Lucy O'Keeffe").person
    assert_nil Result.find_by(name: "Chloe McDonnell").person
  end

  test "asks about Castlebar athletes who aren't on the site, then adds them" do
    import

    assert_redirected_to admin_event_unlinked_results_url(@event)
    follow_redirect!

    result = Result.find_by(name: "Lucy O'Keeffe")

    assert_select "input[name='people[#{result.id}][surname]'][value=?]", "O'Keeffe"

    post admin_event_unlinked_results_url(@event),
         params: { people: { result.id => { create: "1", firstname: "Lucy", surname: "O'Keeffe" } } }

    assert_equal "Lucy O'Keeffe", result.reload.person.fullname
  end
end
