# frozen_string_literal: true

# Who was a member of the club in each year. Membership years run from
# January to December. Not to be confused with memberships, which put people
# in teams.
class CreateClubMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :club_memberships do |t|
      t.references :person, null: false, foreign_key: true
      t.integer :year, null: false
      t.timestamps
    end
    add_index :club_memberships, %i[year person_id], unique: true

    # Athletics Ireland's registration number, the "Reg Life ID" on the
    # club's member list. It stays the same from year to year.
    add_column :people, :aai_number, :string
    add_index :people, :aai_number, unique: true
  end
end
