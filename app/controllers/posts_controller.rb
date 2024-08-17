# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = Current.user

    if @post.save
      redirect_to post_path(@post.id), notice: "Added #{@post.title}"
    else
      render :new
    end
  end

  def show
    @post = Post.find_by_id(params[:id])
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
