# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
    super
  end

  def render?
    !@flash.nil?
  end
end
