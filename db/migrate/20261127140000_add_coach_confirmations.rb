# frozen_string_literal: true

# Some events, like hurdles, throws and jumps, need whoever enters an athlete
# to confirm they've discussed it with a club coach. The entry line records
# who confirmed and when.
class AddCoachConfirmations < ActiveRecord::Migration[8.1]
  def change
    add_column :competition_events, :requires_confirmation, :boolean, default: false, null: false
    add_column :entry_lines, :confirmed_at, :datetime
    add_reference :entry_lines, :confirmed_by, foreign_key: { to_table: :users }

    reversible do |dir|
      dir.up do
        # Events in competitions that are still to happen, as new ones are
        # flagged when they're added
        events = select_rows(<<~SQL.squish)
          SELECT competition_events.id, competition_events.name FROM competition_events
          JOIN competitions ON competitions.id = competition_events.competition_id
          WHERE competitions.status != 'closed'
        SQL
        ids = events.filter_map { |id, name| id.to_i if name.match?(CompetitionEvent::CONFIRMATION_EVENTS) }
        execute "UPDATE competition_events SET requires_confirmation = TRUE WHERE id IN (#{ids.join(',')})" if ids.any?
      end
    end
  end
end
