# frozen_string_literal: true

class CoachesController < ApplicationController
  def index
    authorize :coach, :index?

    @coaches_posts = Coach::Post.order(created_at: :desc).all
  end
end
