# frozen_string_literal: true

class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :results, dependent: :nullify
  has_many :parent_child_relationships,
    class_name: "PersonRelationship",
    foreign_key: :child_id,
    dependent: :destroy
  has_many :parents,
    through: :parent_child_relationships,
    source: :parent

  has_many :child_parent_relationships,
    class_name: "PersonRelationship",
    foreign_key: :parent_id,
    dependent: :destroy
  has_many :children,
    through: :child_parent_relationships,
    source: :child

  before_validation :create_slug

  scope :search, ->(name) { where("LOWER(firstname) LIKE :name OR LOWER(surname) LIKE :name", { name: "#{name}%" }) }

  def create_slug
    return unless firstname_changed? || surname_changed?

    self.slug = I18n.transliterate("#{firstname} #{surname}")
                    .gsub(/\s+/, "-")    # replace spaces with -
                    .gsub(/[^\w]+/, "-") # replace all non-word chars with -
                    .gsub(/--+/, "-")    # replace multiple - with single -
                    .gsub(/^-/, "")      # remove leading -
                    .gsub(/-$/, "")      # remove trailing -
                    .downcase
  end

  def to_param
    slug
  end

  def fullname
    [firstname, surname].join(" ")
  end
end
