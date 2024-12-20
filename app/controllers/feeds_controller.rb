# frozen_string_literal: true

class FeedsController < ApplicationController
  include Pagy::Backend

  allow_unauthenticated_access

  def rss
    @posts = Post.order(created_at: :desc).limit(20)

    render template: "feeds/rss", content_type: "application/rss"
  end
end
