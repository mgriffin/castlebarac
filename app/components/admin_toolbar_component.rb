# frozen_string_literal: true

class AdminToolbarComponent < ViewComponent::Base
  include Pundit::Authorization

  def initialize(user:)
    @user = user
  end

  def render?
    return false if @user.nil?

    policy(:admin).access?
  end

  private

  # Who Pundit checks the policy for
  def pundit_user
    @user
  end
end
