# frozen_string_literal: true

class CoachesPostComponent < ViewComponent::Base
  def initialize(coaches_post:)
    @coaches_post = coaches_post
  end
end
