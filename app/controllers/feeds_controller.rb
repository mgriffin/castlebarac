# frozen_string_literal: true

class FeedsController < ApplicationController
  include Pagy::Backend

  allow_unauthenticated_access

  def rss
    @pagy, @posts = pagy(Post.order(created_at: :desc))

    render template: "feeds/rss", content_type: "application/rss"
  end
end
