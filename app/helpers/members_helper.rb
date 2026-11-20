# frozen_string_literal: true

module MembersHelper
  # How each kind of entry is described in a member list's preview
  MEMBER_LIST_STATUSES = {
    up_to_date: "already up to date",
    update: "to update",
    new: "to add",
    choose: "to choose",
    problem: "that can't be used"
  }.freeze

  # e.g. "3 people on the list: 1 to update and 2 to add."
  def member_list_summary(import)
    counts = MEMBER_LIST_STATUSES.filter_map do |status, words|
      entries = import.entries_with(status)
      "#{entries.size} #{words}" if entries.any?
    end
    "#{pluralize(import.entries.size, 'person')} on the list: #{counts.to_sentence}."
  end

  # e.g. "Liam Walsh, born 2015 (#12)", to tell apart people with one name
  def member_candidate(person)
    born = person.birth_year ? "born #{person.birth_year}" : "year of birth unknown"
    "#{person.fullname}, #{born} (##{person.id})"
  end
end
