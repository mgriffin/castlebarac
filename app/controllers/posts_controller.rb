# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc).group_by { |p| p.created_at.beginning_of_month }
  end

  def show
    @post = Post.find_by(url: params[:id])
  end
end
