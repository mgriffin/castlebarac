# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :races, dependent: :destroy

  has_rich_text :content

  before_validation :create_url, if: :title_changed?

  after_find do |event|
    if event.url.nil?
      event.create_url
      event.save
    end
  end

  def create_url
    self.url = start_time.strftime("%Y-%m-%d-") + title
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
