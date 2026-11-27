# frozen_string_literal: true

# Fills in the distance for races that were loaded without one, so their
# results show under the right distance on people's pages.
#
# - Relays get no distance for now, rather than one leg's distance, so they
#   aren't mixed in with individual races.
# - A 4500m cross country race was saved as 45000m.
# - Where the race's name says how far it is, e.g. "U12 Girls 60m" or
#   "U14 Boys 75mH (0.762m)", that's used.
# - Cross country races named only for the age group take the distance from
#   other races for that age group, and walks and hurdles without a distance
#   in their name take it from the winning times.
#
# Only results without a distance are filled in. Field events have no
# distance, and are left alone.
class FillInRaceDistances < ActiveRecord::Migration[8.1] # rubocop:disable Metrics/ClassLength -- mostly the list of races
  RELAY = /relay|\d\s*x\s*\d/i
  FIELD_EVENT = /jump|\b[HLT]J\b|shot|javelin|discus|hammer|vault|WFD|throw/i

  INFERRED = {
    "National Juvenile B Cross Country" => {
      "Boys U11" => 1000,
      "Girls U11" => 1000,
      "Boys U13" => 2500,
      "Girls U13" => 2500,
      "Boys U15" => 3500,
      "Girls U15" => 3500,
      "Boys U17" => 4500,
      "Girls U17" => 4500
    },
    "Connaught Indoor Championships Day One" => {
      "U14 Girls Hurdles" => 60,
      "U14 Boys Hurdles" => 60,
      "Senior / Master Women Walk" => 1500,
      "U12 Girls Walk" => 1000,
      "U13 Girls Walk" => 1000,
      "U14 Girls Walk" => 1000,
      "U15 Girls Walk" => 1000,
      "U16 Girls Walk" => 1500,
      "U17 Girls Walk" => 1500,
      "U18 Girls Walk" => 1500,
      "U19 Girls Walk" => 1500,
      "U12 Boys Walk" => 1000,
      "U13 Boys Walk" => 1000,
      "U14 Boys Walk" => 1000,
      "U15 Boys Walk" => 1000,
      "U17 Boys Walk" => 1500,
      "U18 Boys Walk" => 1500,
      "U19 Boys Walk" => 1500
    },
    "Connacht Primary Schools Cross Country" => {
      "3rd & 4th Class Girls" => 1000
    },
    "Connacht Cross Country Even Ages" => {
      "U10G" => 1000,
      "U10B" => 1000,
      "U12G" => 2000,
      "U12B" => 2000,
      "U14G" => 3000,
      "U16B" => 4000,
      "U18G" => 4500,
      "U18B" => 4500,
      "Senior Women" => 4500,
      "Senior Men" => 6000,
      "O65 Men" => 4500
    },
    "Connacht Uneven Age Cross Country 2025" => {
      "U13G" => 2500,
      "U13B" => 2500,
      "U15G" => 3500,
      "U15B" => 3500,
      "U17G" => 4500,
      "U17B" => 4500,
      "Senior Women" => 4500,
      "Senior Men" => 6000,
      "O65 Men" => 4500
    },
    "Connacht Indoor Championships Day 1 U12-U14 and Walks" => {
      "Senior / Master Women Walk" => 1500,
      "U12 Girls Walk" => 1000,
      "U13 Girls Walk" => 1000,
      "U14 Girls Walk" => 1000,
      "U15 Girls Walk" => 1000,
      "U16 Girls Walk" => 1500,
      "U17 Girls Walk" => 1500,
      "U18 Girls Walk" => 1500,
      "U19 Girls Walk" => 1500,
      "Senior / Master Men Walk" => 1500,
      "U12 Boys Walk" => 1000,
      "U13 Boys Walk" => 1000,
      "U14 Boys Walk" => 1000,
      "U15 Boys Walk" => 1000,
      "U16 Boys Walk" => 1500,
      "U18 Boys Walk" => 1500
    },
    "Mayo Outdoor Championships Day 2" => {
      "Senior Women Walk" => 3000
    }
  }.freeze

  def up
    execute <<~SQL.squish
      UPDATE results SET distance = NULL
      WHERE race_id IN (SELECT id FROM races WHERE name LIKE '%relay%' OR name LIKE '%4x%' OR name LIKE '%4 x%')
    SQL
    execute "UPDATE results SET distance = 4500 WHERE distance = 45000"

    races_without_distance.each do |race_id, event, name|
      distance = INFERRED.dig(event, name) || distance_in(name)
      next if distance.nil?

      execute "UPDATE results SET distance = #{distance.to_i} WHERE race_id = #{race_id.to_i} AND distance IS NULL"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def races_without_distance
    select_rows(<<~SQL.squish)
      SELECT DISTINCT races.id, events.title, races.name
      FROM races
      JOIN events ON events.id = races.event_id
      JOIN results ON results.race_id = races.id
      WHERE results.distance IS NULL
    SQL
  end

  # e.g. 60 for "60mH (0.84m)", 2000 for "2km Walk"; nil for relays and field
  # events. Brackets are left out, as they give hurdle heights and weights.
  def distance_in(name)
    name = name.gsub(/\([^)]*\)/, " ")
    return if name.match?(RELAY) || name.match?(FIELD_EVENT)

    if (km = name[/(\d+(?:\.\d+)?)\s*km?\b/i, 1])
      (km.to_f * 1000).to_i
    else
      name[/(\d+)\s*m(?:H|\b)/i, 1]&.to_i
    end
  end
end
