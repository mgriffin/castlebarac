# frozen_string_literal: true

# A line is paid for when its payment is, so it doesn't need its own copy
class RemovePaidAtFromEntryLines < ActiveRecord::Migration[8.1]
  def up
    remove_column :entry_lines, :paid_at
  end

  def down
    add_column :entry_lines, :paid_at, :datetime
    execute <<~SQL.squish
      UPDATE entry_lines
      SET paid_at = (SELECT paid_at FROM payments WHERE payments.id = entry_lines.payment_id AND payments.status = 'paid')
    SQL
  end
end
