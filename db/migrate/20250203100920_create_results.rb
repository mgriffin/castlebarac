# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[7.1]
  def change
    create_table :results do |t|
      t.string :name
      t.string :club
      t.decimal :result
      t.integer :heat
      t.integer :bib
      t.string :category
      t.references :race, null: false, foreign_key: true
      t.references :user, null: true

      t.timestamps
    end
  end
end
