# frozen_string_literal: true

class Post < ApplicationRecord
  has_rich_text :content
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  before_validation :create_url, if: :title_changed?

  def create_url
    self.url = DateTime.now.strftime("%Y-%m-%d-") + title
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
    url
  end
end
