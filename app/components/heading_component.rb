# frozen_string_literal: true

class HeadingComponent < ViewComponent::Base
  TAG_OPTIONS = %i[h1 h2 h3 h4 h5 h6].freeze

  def initialize(tag: :h2)
    @tag = TAG_OPTIONS.include?(tag) ? tag : :h2
  end

  def call
    content_tag(@tag, content)
  end
end
