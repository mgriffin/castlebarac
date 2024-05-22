# frozen_string_literal: true

class CreateMailingLists < ActiveRecord::Migration[7.1]
  def change
    create_table :mailing_lists do |t|
      t.string :address

      t.timestamps
    end
  end
end
