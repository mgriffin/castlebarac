# frozen_string_literal: true

module PostsHelper
  def post_permalink(post)
    date = post.created_at
    post_permalink_path(year: date.year, month: date.month, id: post.url)
  end
end
