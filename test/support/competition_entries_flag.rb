# frozen_string_literal: true

# Turns the comp-entries flag on for every test in the class
module CompetitionEntriesFlag
  extend ActiveSupport::Concern

  included do
    setup { Flipper.enable("comp-entries") }
  end
end
