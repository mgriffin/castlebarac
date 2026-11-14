# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true

  has_many :posts, dependent: :nullify
  # A user's person is only ever one they created themselves or one an admin
  # linked them to. It's never matched up by name, as anyone can type a name.
  has_one :person, dependent: :nullify

  def name
    person&.fullname
  end

  # Teams belong to people, so a user without a person isn't in any
  def teams
    person ? person.teams : Team.none
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

  # Admins, coaches and committee members
  def staff?
    teams.exists?(name: %w[Admins Coaches Committee])
  end
end
