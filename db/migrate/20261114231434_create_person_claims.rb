# frozen_string_literal: true

# Someone asking for an existing person to be linked to their account, for
# an admin to approve or reject
class CreatePersonClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :person_claims do |t|
      t.references :user, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :person_claims, :user_id, unique: true, where: "status = 'pending'",
                                        name: "index_person_claims_on_pending_user_id"
  end
end
