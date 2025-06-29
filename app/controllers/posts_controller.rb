# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc).group_by { |p| p.created_at.beginning_of_month }
  end

  def show
    @post = Post.find_by(url: params[:id])
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find_by(url: params[:id])
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if @post.save
      redirect_to post_path(@post), notice: "Added #{@post.title}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find_by(url: params[:id])

    if @post.update(post_params)
      redirect_to post_path(@post), notice: "Updated #{@post.title}"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.expect(post: %i[title content])
  end
end
