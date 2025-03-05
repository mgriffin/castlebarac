# frozen_string_literal: true

class AddSlugToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :slug, :string
  end
end
