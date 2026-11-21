# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true

  # Logging in and resetting passwords aren't changes worth posting
  self.site_activity_ignored_fields += %w[
    sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip
    remember_created_at reset_password_token reset_password_sent_at
  ]

  has_many :posts, dependent: :nullify
  has_many :entries, dependent: :destroy
  # A user's person is only ever one they created themselves or one an admin
  # linked them to. It's never matched up by name, as anyone can type a name.
  has_one :person, dependent: :nullify
  has_many :person_claims, dependent: :destroy
  has_many :child_claims, dependent: :destroy
  has_many :reviewed_person_claims, class_name: "PersonClaim", foreign_key: :reviewed_by_id,
                                    inverse_of: :reviewed_by, dependent: :nullify
  has_many :reviewed_child_claims, class_name: "ChildClaim", foreign_key: :reviewed_by_id,
                                   inverse_of: :reviewed_by, dependent: :nullify

  def name
    person&.fullname
  end

  # Teams belong to people, so a user without a person isn't in any
  def teams
    person ? person.teams : Team.none
  end

  def admin?
    team_names.include?("Admins")
  end

  def coach?
    team_names.include?("Coaches")
  end

  def committee?
    team_names.include?("Committee")
  end

  # Admins, coaches and committee members
  def staff?
    team_names.intersect?(%w[Admins Coaches Committee])
  end

  def reload(...)
    @team_names = nil
    super
  end

  def flipper_id
    person&.slug
  end

  private

  # Pages check these roles many times, e.g. once for each result, so the
  # names are loaded once. current_user is a new object on every request.
  def team_names
    @team_names ||= teams.pluck(:name)
  end
end
