# frozen_string_literal: true

class CreateCompetitions < ActiveRecord::Migration[8.1]
  def change
    create_table :competitions do |t|
      t.string :name, limit: 256, null: false
      t.string :slug, null: false
      t.string :venue
      t.string :level, null: false
      t.date :date, null: false
      t.datetime :entries_close_at, null: false
      t.string :status, null: false, default: "draft"
      t.integer :max_events_per_athlete
      t.integer :fee_per_event_cents, null: false, default: 0
      t.references :event, foreign_key: true

      t.timestamps
    end
    add_index :competitions, :slug, unique: true
  end
end
