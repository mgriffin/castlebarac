# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true

  has_many :posts, dependent: :nullify
  has_one :person, dependent: :nullify
  accepts_nested_attributes_for :person

  before_create :find_or_create_person

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

  private

  def find_or_create_person
    firstname, surname = username.split
    surname = "" if surname.nil?

    self.person = Person.find_or_create_by(firstname:, surname:)
  end
end
