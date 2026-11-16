# frozen_string_literal: true

class CreateEntryLines < ActiveRecord::Migration[8.1]
  def change
    create_table :entry_lines do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.references :competition_event, null: false, foreign_key: true

      t.timestamps
    end
    add_index :entry_lines, %i[person_id competition_event_id], unique: true
  end
end
