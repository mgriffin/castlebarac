# frozen_string_literal: true

class AddResultStringToResults < ActiveRecord::Migration[7.1]
  def change
    change_table :results do |t|
      t.rename :result, :seconds
      t.string :result
      t.integer :position
    end
  end
end
