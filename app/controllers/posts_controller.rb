# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update]

  def index
    authorize Post
    @posts = Post.order(created_at: :desc).group_by { |p| p.created_at.beginning_of_month }
  end

  def show; end

  def new
    @post = Post.new
    authorize @post
  end

  def edit; end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    authorize @post

    if @post.save
      redirect_to post_path(@post), notice: "Added #{@post.title}"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "Updated #{@post.title}"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_post
    @post = Post.find_by!(url: params.expect(:id))
    authorize @post
  end

  def post_params
    params.expect(post: %i[title content])
  end
end
