# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships

  before_validation :create_slug, if: :name_changed?

  def create_slug
    self.slug = name
                .gsub(/\s+/, "-")        # replace spaces with -
                .gsub("&", "-and-")      # replace & with -and-
                .gsub(%r{[^\w\-/]+}, "") # remove all non-word chars except - and /
                .gsub(%r{/}, "-")        # replace / with -
                .gsub(/--+/, "-")        # replace multiple - with single -
                .gsub(/^-/, "")          # remove leading -
                .gsub(/-$/, "")          # remove trailing -
                .downcase
  end

  def to_param
    slug
  end
end
