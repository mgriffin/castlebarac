# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @comment = @commentable.comments.new comment_params
    authorize @comment

    @comment.user = current_user

    @comment.save
    redirect_to @commentable, notice: t(".notice")
  end

  private

  def comment_params
    params.expect(comment: %i[body])
  end
end
