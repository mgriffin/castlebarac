# frozen_string_literal: true

module PeopleHelper
  GENDER_LABELS = { "female" => "Girl / woman", "male" => "Boy / man" }.freeze

  # Keeps a gender we don't know how to label, so saving doesn't lose it
  def gender_options(person)
    options = GENDER_LABELS.invert.to_a
    options << [person.gender, person.gender] if person.gender.present? && GENDER_LABELS.exclude?(person.gender)
    options
  end
end
