# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  def render?
    !@flash.nil?
  end
end
