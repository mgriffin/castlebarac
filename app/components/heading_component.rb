# frozen_string_literal: true

class HeadingComponent < ViewComponent::Base
  def initialize(level: "h2")
    @level = level
  end
end
