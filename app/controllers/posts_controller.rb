# frozen_string_literal: true

class PostsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @posts = pagy(Post.order(created_at: :desc))
  end

  def show
    @post = Post.find(params[:id])
  end
end
