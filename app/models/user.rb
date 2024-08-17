# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :posts

  has_secure_password validations: false
end
