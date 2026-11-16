# frozen_string_literal: true

class AddPaymentToEntryLines < ActiveRecord::Migration[8.1]
  def change
    add_reference :entry_lines, :payment, foreign_key: true
    add_column :entry_lines, :paid_at, :datetime
  end
end
