# frozen_string_literal: true

# Sessions for the login that Devise replaced
class DropSessions < ActiveRecord::Migration[8.1]
  def change
    drop_table :sessions do |t|
      t.datetime :last_active_at, null: false
      t.string :token, null: false
      t.string :ip_address
      t.string :user_agent
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
