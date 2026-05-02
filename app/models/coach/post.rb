# frozen_string_literal: true

module Coach
  class Post < ApplicationRecord
    extend FriendlyId

    friendly_id :date_and_title, use: :slugged

    has_rich_text :content
    belongs_to :user

    def date_and_title
      "#{(created_at || Time.zone.now).strftime('%Y-%m-%d')} #{title}"
    end
  end
end
