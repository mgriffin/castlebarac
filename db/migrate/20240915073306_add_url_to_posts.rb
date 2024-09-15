# frozen_string_literal: true

class AddUrlToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :url, :string
  end
end
