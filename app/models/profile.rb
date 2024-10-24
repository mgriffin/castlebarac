# frozen_string_literal: true

class Profile < ApplicationRecord
  self.table_name = "people"
  belongs_to :user
end
