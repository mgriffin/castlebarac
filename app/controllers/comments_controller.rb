# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = @commentable.comments.new comment_params
    @comment.user = current_user

    @comment.save
    redirect_to @commentable, notice: t(".notice")
  end

  private

  def comment_params
    params.expect(comment: %i[body])
  end
end
