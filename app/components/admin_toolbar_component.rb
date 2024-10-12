# frozen_string_literal: true

class AdminToolbarComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
    super
  end

  def render?
    @user.present? && @user.admin?
  end
end
