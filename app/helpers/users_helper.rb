module UsersHelper
  include Pagy::Frontend

  def approve_link(user)
    button_to user_path(user), method: :patch, params: { user: { approved: true } } do
      image_tag("approve.png")
    end
  end

  def unapprove_link(user)
    button_to user_path(user), method: :patch, params: { user: { approved: false } } do
      image_tag("disapprove.png")
    end
  end
end
