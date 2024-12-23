# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :races, dependent: :destroy

  has_rich_text :content
end
