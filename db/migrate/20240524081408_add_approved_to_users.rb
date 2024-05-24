class AddApprovedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :approved, :boolean, default: false
  end
end
