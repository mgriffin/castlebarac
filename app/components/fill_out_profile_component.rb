# frozen_string_literal: true

class FillOutProfileComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

  def render?
    !@user.nil? && @user.person.nil?
  end
end
