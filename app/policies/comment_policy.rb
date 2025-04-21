# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    user
  end

  def create?
    user
  end
end
