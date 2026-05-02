# frozen_string_literal: true

module Coaches
  class PostsController < ApplicationController
    def show
      @coach_post = Coach::Post.friendly.find(params[:id])
      authorize @coach_post
    end

    def new
      @coach_post = Coach::Post.new
      authorize @coach_post
    end

    def create
      @coach_post = Coach::Post.new(coach_post_params)
      authorize @coach_post

      @coach_post.user = current_user

      if @coach_post.save
        redirect_to coaches_path, notice: "Added #{@coach_post.title}"
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def coach_post_params
      params.expect(coach_post: %i[title content])
    end
  end
end
