# frozen_string_literal: true

class AddSlugToCoachPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :coach_posts, :slug, :string
    add_index :coach_posts, :slug, unique: true
  end
end
