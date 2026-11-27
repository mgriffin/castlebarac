# frozen_string_literal: true

module PeopleHelper
  GENDER_LABELS = { "female" => "Girl / woman", "male" => "Boy / man" }.freeze

  # Keeps a gender we don't know how to label, so saving doesn't lose it
  def gender_options(person)
    options = GENDER_LABELS.invert.to_a
    options << [person.gender, person.gender] if person.gender.present? && GENDER_LABELS.exclude?(person.gender)
    options
  end

  # e.g. "Mary Example and John Example", linked to their pages
  def people_links(people)
    to_sentence(people.map { link_to(it.fullname, person_path(it)) })
  end

  # e.g. "Member 2019, 2021–2026", or nil if they've never been a member
  def member_years_label(years)
    return if years.empty?

    spans = years.slice_when { |year, following| following != year + 1 }
    "Member #{spans.map { it.many? ? "#{it.first}–#{it.last}" : it.first }.join(', ')}"
  end

  # The fastest of the times, if there's more than one to compare
  def personal_best(results)
    timed = results.select(&:time?)
    timed.min_by(&:seconds) if timed.many?
  end

  # 1st to 3rd get a medal, as on the event page
  def result_position(result)
    return unless result.placed?

    result.medal? ? medal(result.position) : result.position.ordinalize
  end
end
