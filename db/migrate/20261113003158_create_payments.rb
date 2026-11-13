# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :entry, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :status, null: false, default: "pending"
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.datetime :paid_at

      t.timestamps
    end
    add_index :payments, :stripe_checkout_session_id, unique: true
  end
end
