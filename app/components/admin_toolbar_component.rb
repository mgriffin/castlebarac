# frozen_string_literal: true

class AdminToolbarComponent < ViewComponent::Base
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  def render?
    policy(:admin_toolbar).show?
  end
end
