# frozen_string_literal: true

# Saves races from a results website (see ResultSources) onto an event.
# Importing the same race again updates its results rather than adding them
# twice.
class ResultImport
  # A race to import, with the name and distance to save it with
  Selection = Struct.new(:key, :name, :distance, keyword_init: true)

  # Results pages write our club's name in different ways
  CLUB_NAMES = { /\Acastlebar\s+a\.?\s*c\.?\z/i => "Castlebar A.C." }.freeze

  attr_reader :source, :event, :selections

  def initialize(source:, event:, selections:)
    @source = source
    @event = event
    @selections = selections
  end

  # Returns the number of results saved
  def call
    rows = selections.index_with { |selection| source.results_for(selection.key) }

    Result.transaction do
      rows.sum { |selection, results| save_race(selection, results) }
    end
  end

  private

  def save_race(selection, rows)
    race = event.races.find_or_create_by!(name: selection.name)

    rows.each do |row|
      result = race.results.find_or_initialize_by(bib: row.bib_number, name: row.name)
      result.update!(
        club: club_name(row.club),
        position: row.position_number,
        result: row.time,
        seconds: row.seconds,
        distance: selection.distance,
        category: selection.name
      )
    end

    rows.size
  end

  def club_name(club)
    CLUB_NAMES.find { |pattern, _| pattern.match?(club.to_s.squish) }&.last || club
  end
end
