# frozen_string_literal: true

class PostsController < ApplicationController
  include Pagy::Backend

  allow_unauthenticated_access

  def index
    @pagy, @posts = pagy(Post.order(created_at: :desc))
  end

  def show
    @post = Post.find_by(url: params[:id])
  end
end
