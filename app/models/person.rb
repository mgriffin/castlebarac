# frozen_string_literal: true

class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  before_validation :create_slug

  def create_slug
    return unless firstname_changed? || surname_changed?

    self.slug = "#{firstname} #{surname}"
                .gsub(/\s+/, "-")    # replace spaces with -
                .gsub(/[^\w]+/, "-") # replace all non-word chars with -
                .gsub(/--+/, "-")    # replace multiple - with single -
                .gsub(/^-/, "")      # remove leading -
                .gsub(/-$/, "")      # remove trailing -
                .downcase
  end
end
