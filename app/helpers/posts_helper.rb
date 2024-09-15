# frozen_string_literal: true

module PostsHelper
  def post_permalink(e)
    d = e.created_at
    post_permalink_path year: d.year, month: d.month, id: e.url
  end
end
