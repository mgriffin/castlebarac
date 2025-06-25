# frozen_string_literal: true

class CreatePersonRelationshipsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table "person_relationships", force: true do |t|
      t.integer  "parent_id"
      t.integer  "child_id"

      t.timestamps
    end
  end
end
