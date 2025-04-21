# frozen_string_literal: true

class AdminToolbarComponent < ViewComponent::Base
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  def initialize(user:)
    @current_user = user
    super
  end

  def render?
    return false if @current_user.nil?

    policy(:admin_toolbar).show?
  end
end
