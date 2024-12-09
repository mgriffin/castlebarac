# frozen_string_literal: true

class Person < ApplicationRecord
  belongs_to :user, optional: true
end
