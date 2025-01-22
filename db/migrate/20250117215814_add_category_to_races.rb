class AddCategoryToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :category, :string
  end
end
