# frozen_string_literal: true

class Race < ApplicationRecord
  belongs_to :event
  has_many :results, dependent: :destroy
end
