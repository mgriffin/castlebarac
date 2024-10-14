# frozen_string_literal: true

class ListPostsComponent < ViewComponent::Base
  renders_many :posts, "PostComponent"

  class PostComponent < ViewComponent::Base
    def initialize(post)
      @post = post
      super
    end
  end
end
