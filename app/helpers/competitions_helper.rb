# frozen_string_literal: true

module CompetitionsHelper
  # The years athletes in an event were born in, e.g. "2015" or "2014–2015"
  def birth_years(event)
    first = event.earliest_birth_year
    last = event.latest_birth_year

    return [first, last].uniq.join("–") if first && last
    return "#{first} or later" if first

    "#{last} or earlier" if last
  end

  def euros(cents)
    number_to_currency(cents / 100.0, unit: "€")
  end
end
