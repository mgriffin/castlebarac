# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships
end
