# frozen_string_literal: true

module MembersHelper
  # e.g. "Liam Walsh, born 2015 (#12)", to tell apart people with one name
  def member_candidate(person)
    born = person.birth_year ? "born #{person.birth_year}" : "year of birth unknown"
    "#{person.fullname}, #{born} (##{person.id})"
  end
end
