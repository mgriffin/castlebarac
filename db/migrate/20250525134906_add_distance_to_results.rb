# frozen_string_literal: true

class AddDistanceToResults < ActiveRecord::Migration[8.0]
  def change
    add_column :results, :distance, :integer
  end
end
