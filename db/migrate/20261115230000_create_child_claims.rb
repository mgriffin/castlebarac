# frozen_string_literal: true

# A parent asking to be linked to their child, for an admin to approve or
# reject
class CreateChildClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :child_claims do |t|
      t.references :user, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: { to_table: :people }
      t.string :status, null: false, default: "pending"
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :child_claims, %i[user_id child_id], unique: true, where: "status = 'pending'",
                                                   name: "index_child_claims_on_pending_user_id_and_child_id"
  end
end
