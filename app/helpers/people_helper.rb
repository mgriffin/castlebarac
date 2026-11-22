# frozen_string_literal: true

module PeopleHelper
  GENDER_LABELS = { "female" => "Girl / woman", "male" => "Boy / man" }.freeze

  # Keeps a gender we don't know how to label, so saving doesn't lose it
  def gender_options(person)
    options = GENDER_LABELS.invert.to_a
    options << [person.gender, person.gender] if person.gender.present? && GENDER_LABELS.exclude?(person.gender)
    options
  end

  # e.g. "AE" for Aoife Example
  def initials(person)
    [person.firstname, person.surname].filter_map { it.to_s[0] }.join.upcase
  end

  # e.g. "Member 2019, 2021–2026", or nil if they've never been a member
  def member_years_label(years)
    return if years.empty?

    spans = years.slice_when { |year, following| following != year + 1 }
    "Member #{spans.map { it.many? ? "#{it.first}–#{it.last}" : it.first }.join(', ')}"
  end

  # A time like 9.85, 4:31 or 1:02:05.4, or else what the results say, e.g.
  # a distance jumped or DNF
  def result_mark(result)
    return result.result.presence || "–" unless result.seconds.to_f.positive?

    hours, rest = result.seconds.to_f.divmod(3600)
    minutes, seconds = rest.divmod(60)
    hours = hours.to_i
    minutes = minutes.to_i
    seconds = format("%05.2f", seconds).sub(/\.?0+\z/, "")
    return "#{hours}:#{format('%02d', minutes)}:#{seconds}" if hours.positive?
    return "#{minutes}:#{seconds}" if minutes.positive?

    seconds.delete_prefix("0")
  end

  # The fastest of the times, if there's more than one to compare
  def personal_best(results)
    timed = results.select { it.seconds.to_f.positive? }
    timed.min_by(&:seconds) if timed.many?
  end

  # 1st to 3rd get a medal, as on the event page
  def result_position(result)
    return if result.position.nil?
    return tag.span(result.position, class: "medal medal--#{result.position}") if (1..3).cover?(result.position)

    result.position.ordinalize
  end
end
