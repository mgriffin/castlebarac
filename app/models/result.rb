# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :race
  belongs_to :user, optional: true
end
