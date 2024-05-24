class User < ApplicationRecord
  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where(approved: false) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
