# frozen_string_literal: true

class CreateCompetitionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :competition_events do |t|
      t.references :competition, null: false, foreign_key: true
      t.string :name, null: false
      t.string :distance
      t.string :age_group
      t.integer :min_age
      t.integer :max_age
      t.string :gender
      t.time :start_time
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
