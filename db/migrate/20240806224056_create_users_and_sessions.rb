# frozen_string_literal: true

class CreateUsersAndSessions < ActiveRecord::Migration[7.1]
  def change
    create_table "users" do |t|
      t.string "email", null: false
      t.string "password_digest", null: false
      t.timestamps null: false
    end

    create_table "sessions" do |t|
      t.string "user_agent"
      t.string "ip_address"
      t.string "token", null: false
      t.datetime "last_active_at", null: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end
  end
end
