# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    user
  end
end
