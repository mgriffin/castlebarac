# frozen_string_literal: true

class CoachesController < ApplicationController
  def index
    authorize :coach, :index?

    @coaches_posts = Coach::Post.all
  end
end
