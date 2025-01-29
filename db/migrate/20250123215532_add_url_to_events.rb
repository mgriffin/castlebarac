# frozen_string_literal: true

class AddUrlToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :url, :string
  end
end
