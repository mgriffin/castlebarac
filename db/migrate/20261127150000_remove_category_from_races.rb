# frozen_string_literal: true

# A race's category was only ever a copy of its name, and nothing reads it
class RemoveCategoryFromRaces < ActiveRecord::Migration[8.1]
  def change
    remove_column :races, :category, :string
  end
end
