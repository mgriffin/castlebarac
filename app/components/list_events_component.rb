# frozen_string_literal: true

class ListEventsComponent < ViewComponent::Base
  renders_many :events, "EventComponent"

  class EventComponent < ViewComponent::Base
    def initialize(event)
      @event = event
      super
    end
  end
end
