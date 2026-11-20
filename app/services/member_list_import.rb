# frozen_string_literal: true

# Makes a year's member list on the site match the club's member list.
#
# Each row is matched to a person by their AAI number, or the first time by
# their name and year of birth. Matched people get the list's AAI number,
# year of birth and gender. People who can't be found are added. When a name
# fits more than one person, or someone whose year of birth doesn't match,
# an admin chooses. Members who aren't on the list are taken off that year's
# list, but nobody is deleted.
#
# Importing the same list for the same year again changes nothing.
class MemberListImport
  # status is one of:
  #   :up_to_date - nothing to change
  #   :update     - person needs the changes listed
  #   :new        - nobody matches, so a person will be added
  #   :choose     - an admin needs to choose from the candidates, or chose to
  #                 leave them out for now
  #   :problem    - the row can't be used, for the reason in problem
  Entry = Struct.new(:row, :status, :person, :candidates, :changes, :problem, keyword_init: true)

  NEW = "new"
  LEAVE_OUT = "leave_out"

  attr_reader :year

  # choices: { aai_number => person id, NEW or LEAVE_OUT } for rows where an
  # admin had to choose
  def initialize(rows:, year:, choices: {})
    @rows = rows
    @year = year
    @choices = choices.to_h.transform_keys(&:to_s)
  end

  def entries
    @entries ||= build_entries
  end

  def entries_with(status)
    (@by_status ||= entries.group_by(&:status)).fetch(status, [])
  end

  # This year's members who aren't on the list
  def leavers
    @leavers ||= Person.members_in(year).where.not(id: entries.filter_map { it.person&.id })
                       .order(:surname, :firstname).to_a
  end

  def changes?
    leavers.any? || entries_with(:update).any? || entries_with(:new).any?
  end

  # Returns the number of people added, updated and taken off the list
  def apply!
    added = entries_with(:new)
    updated = entries_with(:update)

    ActiveRecord::Base.transaction do
      ClubMembership.where(year:, person: leavers).delete_all
      added.each { add(it.row) }
      updated.each { update(it.person, it.row) }
    end
    { added: added.size, updated: updated.size, removed: leavers.size }
  end

  private

  def build_entries
    seen = Set.new
    claimed = Set.new

    @rows.map do |row|
      entry = entry_for(row, seen, claimed)
      seen << row.aai_number
      claimed << entry.person.id if entry.person
      entry
    end
  end

  def entry_for(row, seen, claimed)
    return Entry.new(row:, status: :problem, problem: row.problem) if row.problem
    if seen.include?(row.aai_number)
      return Entry.new(row:, status: :problem, problem: "This Reg Life ID is on the list twice")
    end
    return found(row, by_aai[row.aai_number]) if by_aai[row.aai_number]

    candidates = Person.named(row.fullname).select { it.aai_number.nil? && claimed.exclude?(it.id) }
    chosen(row, candidates) || matched(row, candidates)
  end

  # What an admin chose for this row, if anything
  def chosen(row, candidates)
    case (choice = @choices[row.aai_number])
    when nil, "", LEAVE_OUT then nil
    when NEW then Entry.new(row:, status: :new)
    else
      person = candidates.find { it.id.to_s == choice }
      found(row, person) if person
    end
  end

  # The one person with this name and year of birth (or none recorded), or
  # else a choice for an admin
  def matched(row, candidates)
    return Entry.new(row:, status: :new) if candidates.empty?

    same_year = candidates.select { it.birth_year.nil? || it.birth_year == row.year }
    return found(row, same_year.first) if same_year.one?

    Entry.new(row:, status: :choose, candidates:)
  end

  def found(row, person)
    changes = changes(person, row)
    Entry.new(row:, person:, changes:, status: changes.any? ? :update : :up_to_date)
  end

  def by_aai
    @by_aai ||= Person.where(aai_number: @rows.map(&:aai_number).compact_blank).index_by(&:aai_number)
  end

  def members
    @members ||= Person.members_in(year).pluck(:id).to_set
  end

  def changes(person, row)
    [
      ("Add to the #{year} list" unless members.include?(person.id)),
      ("Set the AAI number to #{row.aai_number}" if person.aai_number.nil?),
      change("year of birth", person.year, row.year.to_s),
      change("gender", person.gender, row.gender)
    ].compact
  end

  def change(name, from, to)
    return if from == to

    from.nil? ? "Set the #{name} to #{to}" : "Change the #{name} from #{from} to #{to}"
  end

  def add(row)
    person = Person.create!(firstname: Person.tidy_name(row.firstname), surname: Person.tidy_name(row.surname),
                            aai_number: row.aai_number, year: row.year.to_s, gender: row.gender)
    person.club_memberships.create!(year:)
  end

  def update(person, row)
    person.update!(aai_number: person.aai_number || row.aai_number, year: row.year.to_s, gender: row.gender)
    person.club_memberships.find_or_create_by!(year:)
  end
end
