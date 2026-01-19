# frozen_string_literal: true

class AddGenderToPerson < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :gender, :string
  end
end
