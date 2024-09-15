# frozen_string_literal: true

class Post < ApplicationRecord
  has_rich_text :content
  belongs_to :user

  acts_as_url :title

  def to_param
    url
  end
end
