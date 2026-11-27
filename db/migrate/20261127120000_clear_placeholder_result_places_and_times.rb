# frozen_string_literal: true

# Some results were loaded with a place of 0 and the largest possible time
# for anyone who didn't finish (DNS, DNF, NM, DQ), so they'd sort last. They
# showed as "0th" and a very long time, so they're cleared, leaving what the
# results say, e.g. DNS.
class ClearPlaceholderResultPlacesAndTimes < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE results SET position = NULL WHERE position = 0"
    execute "UPDATE results SET seconds = NULL WHERE seconds >= #{Result::MAX_SECONDS}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
