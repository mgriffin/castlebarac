class CreatePerson < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.string :firstname, null: false, limit: 256
      t.string :surname, null: false, limit: 256
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
