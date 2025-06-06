# frozen_string_literal: true

class AdminToolbarPolicy < ApplicationPolicy
  attr_reader :user

  def show?
    return false if @user.nil?
    return false if @user.person.nil?

    @user.teams.exists?(name: "Admins")
  end
end
