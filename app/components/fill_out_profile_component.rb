# frozen_string_literal: true

class FillOutProfileComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
    super
  end

  def render?
    !@user.nil? && @user.profile.nil?
  end
end
