# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :nullify
  has_one :profile, dependent: :nullify

  has_secure_password validations: false
end
