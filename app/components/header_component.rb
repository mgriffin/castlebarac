# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  def initialize(user_signed_in:)
    @user_signed_in = user_signed_in
  end

  def user_signed_in?
    !!@user_signed_in
  end
end
