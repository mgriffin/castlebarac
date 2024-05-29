module UsersHelper
  include Pagy::Frontend

  def approve_link(user)
    link_to user_path(user, user: { approved: true }), 'data-turbo-method': :patch do
      image_tag("approve.png", alt: "Approve #{user.email}")
    end
  end

  def unapprove_link(user)
    link_to user_path(user, user: { approved: false }), 'data-turbo-method': :patch do
      image_tag("disapprove.png", alt: "Unapprove #{user.email}")
    end
  end
end
