# frozen_string_literal: true

module ApplicationHelper
  def distance_to_human(distance)
    return "" if distance.nil?

    case distance
    when 0..4999
      "#{distance}m"
    else
      "#{distance / 1000}km"
    end
  end

  # A position in a circle coloured gold, silver or bronze
  def medal(position)
    tag.span(position, class: "medal medal--#{position}")
  end

  # "3 days ago", with the full date and time when you hover over it
  def time_ago_tag(time)
    return if time.nil?

    time_tag time, "#{time_ago_in_words(time)} ago", title: l(time, format: :long)
  end
end
