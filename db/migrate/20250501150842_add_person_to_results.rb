class AddPersonToResults < ActiveRecord::Migration[8.0]
  def change
    change_table :results do |t|
      t.references :person, null: true
      t.remove_references :user, null: true
    end
  end
end
