class HeaderComponentPreview < ViewComponent::Preview
  def with_login_feature_flag_disabled
    Flipper.disable :login
    render HeaderComponent.new(user_signed_in: false)
  end

  def with_logged_out_user
    Flipper.enable :login
    render HeaderComponent.new(user_signed_in: false)
  end

  def with_logged_in_user
    Flipper.enable :login
    render HeaderComponent.new(user_signed_in: true)
  end
end
