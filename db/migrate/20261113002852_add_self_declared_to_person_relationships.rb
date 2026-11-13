# frozen_string_literal: true

class AddSelfDeclaredToPersonRelationships < ActiveRecord::Migration[8.1]
  def change
    add_column :person_relationships, :self_declared, :boolean, null: false, default: false
  end
end
