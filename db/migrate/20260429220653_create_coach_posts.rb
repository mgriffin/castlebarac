# frozen_string_literal: true

class CreateCoachPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :coach_posts do |t|
      t.string :title, null: false, limit: 256
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
