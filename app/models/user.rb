# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :nullify
  has_one :person, dependent: :nullify
  accepts_nested_attributes_for :person

  delegate :teams, to: :person

  def name
    person&.fullname
  end

  def admin?
    teams.exists?(name: "Admins")
  end

  def coach?
    teams.exists?(name: "Coaches")
  end

  def committee?
    teams.exists?(name: "Committee")
  end

  def thredded_admin?
    admin?
  end
end
