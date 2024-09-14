# frozen_string_literal: true

class ListComponent < ViewComponent::Base
  renders_many :items, "ItemComponent"

  class ItemComponent < ViewComponent::Base
    def initialize(label:, href:)
      @label = label
      @href = href
    end

    def call
      link_to @label, @href
    end
  end
end
