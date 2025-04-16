# frozen_string_literal: true

class Admin::UserPolicy < ApplicationPolicy
  def index?
    user && user.teams.exists?(name: "Admins")
  end
end
