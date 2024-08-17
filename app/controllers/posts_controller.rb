# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user!

  def show
    @post = Post.find_by(params[:id])
  end

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

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
