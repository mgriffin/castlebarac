# frozen_string_literal: true

# An account is linked to one person at most. Before the sign-up fix, an
# account could end up linked to more than one, which this refuses to tidy
# up by guessing: unlink the extra people first.
class MakePeopleUserIdUnique < ActiveRecord::Migration[8.1]
  def up
    shared = select_values("SELECT user_id FROM people WHERE user_id IS NOT NULL GROUP BY user_id HAVING COUNT(*) > 1")
    if shared.any?
      raise "Some accounts are linked to more than one person (user IDs #{shared.join(', ')}). " \
            "Unlink the extra people before running this migration."
    end

    remove_index :people, :user_id
    add_index :people, :user_id, unique: true
  end

  def down
    remove_index :people, :user_id
    add_index :people, :user_id
  end
end
