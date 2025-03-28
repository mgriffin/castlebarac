# frozen_string_literal: true

class CreateTeamsAndMemberships < ActiveRecord::Migration[8.0]
  def change
    drop_table :teams, if_exists: true do |t|
      t.string "name"
    end

    drop_table :memberships, if_exists: true do |t|
      t.integer "team_id"
    end

    create_table :teams do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end

    create_table :memberships do |t|
      t.references :person, foreign_key: true
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
