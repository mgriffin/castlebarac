# frozen_string_literal: true

module ApplicationHelper
  def distance_to_human(distance)
    case distance
    when 0..4999
      "#{distance}m"
    else
      "#{distance / 1000}km"
    end
  end
end
