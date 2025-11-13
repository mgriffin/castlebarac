class CreateTimeTrials < ActiveRecord::Migration[8.0]
  def change
    create_table :time_trials do |t|
      t.integer :distance
      t.string :surface
      t.date :recorded_at, null: false

      t.timestamps
    end

    create_table :tt_times do |t|
      t.decimal :seconds
      t.references :person, null: false, foreign_key: true
      t.references :time_trial, null: false, foreign_key: true

      t.timestamps
    end
  end
end
