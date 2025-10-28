# frozen_string_literal: true

class AddCountyToResults < ActiveRecord::Migration[8.0]
  def change
    add_column :results, :county, :string
  end
end
