# frozen_string_literal: true

# A parent and child can only be linked once. Duplicate links are the same
# two people linked again, so the extras are deleted, keeping the oldest.
class AddUniqueIndexToPersonRelationships < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      DELETE FROM person_relationships
      WHERE id NOT IN (SELECT MIN(id) FROM person_relationships GROUP BY parent_id, child_id)
    SQL

    add_index :person_relationships, %i[parent_id child_id], unique: true
    add_index :person_relationships, :child_id
  end

  def down
    remove_index :person_relationships, :child_id
    remove_index :person_relationships, %i[parent_id child_id]
  end
end
