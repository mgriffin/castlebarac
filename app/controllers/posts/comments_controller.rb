# frozen_string_literal: true

class Posts::CommentsController < CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Post.find_by(url: params[:post_id])
  end
end
