# frozen_string_literal: true

class AddYearToPerson < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :year, :string
  end
end
