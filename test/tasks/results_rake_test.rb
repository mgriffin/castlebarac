# frozen_string_literal: true

require "test_helper"
require "rake"

class ResultsRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["results:link"].reenable
    @race = events(:first).races.create!(name: "U9 Girls")
  end

  def run_task(input)
    $stdin = StringIO.new(input)
    capture_io { Rake::Task["results:link"].invoke }.first
  ensure
    $stdin = STDIN
  end

  test "links matches and creates people, suggesting their names" do
    match = @race.results.create!(name: "Snörí SNÖRÍSSØŇ", club: "Castlebar A.C.", position: 1)
    new_athlete = @race.results.create!(name: "Juliette NIC SUIBHNE", club: "Castlebar A.C.", position: 2)
    skipped = @race.results.create!(name: "Not Wanted", club: "Castlebar A.C.", position: 3)

    # Accept the suggested names for Juliette, then say no to the next one
    output = run_task("y\n\n\nn\n")

    assert_equal people(:snori), match.reload.person
    assert_equal "Juliette Nic Suibhne", new_athlete.reload.person.fullname
    assert_nil skipped.reload.person
    assert_includes output, "What's their surname? (Nic Suibhne)"
  end
end
