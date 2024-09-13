# frozen_string_literal: true

class Event < ApplicationRecord
  has_rich_text :content
end
