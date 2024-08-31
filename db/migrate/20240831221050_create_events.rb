class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title, null: false, limit: 256
      t.datetime :start_time, null: false
      t.timestamps
    end
  end
end
