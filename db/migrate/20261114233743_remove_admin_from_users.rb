# frozen_string_literal: true

# Admins are the members of the Admins team, so this flag was never read
class RemoveAdminFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :admin, :boolean, default: false, null: false
  end
end
