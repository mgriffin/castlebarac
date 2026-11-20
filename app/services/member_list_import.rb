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
  #   :choose     - an admin needs to choose from the candidates
  #   :left_out   - an admin chose to leave them out for now
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

  def entries_with(status) = entries.select { it.status == status }

  # This year's members who aren't on the list
  def leavers
    @leavers ||= Person.members_in(year).where.not(id: entries.filter_map { it.person&.id }).order(:surname, :firstname)
  end

  def changes?
    leavers.any? || entries.any? { %i[update new].include?(it.status) }
  end

  # Returns the number of people added, updated and taken off the list
  def apply!
    counts = { added: entries_with(:new).size, updated: entries_with(:update).size, removed: leavers.size }

    ActiveRecord::Base.transaction do
      ClubMembership.where(year:, person_id: leavers.select(:id)).delete_all
      entries_with(:new).each { add(it) }
      entries_with(:update).each { update(it) }
    end
    counts
  end

  private

  def build_entries
    by_aai = Person.where(aai_number: @rows.map(&:aai_number).compact_blank).index_by(&:aai_number)
    members = Person.members_in(year).pluck(:id).to_set
    seen = Set.new
    claimed = Set.new

    @rows.map do |row|
      entry = entry_for(row, by_aai, seen, claimed)
      seen << row.aai_number
      if entry.person
        claimed << entry.person.id
        entry.changes = changes(entry.person, row, members)
        entry.status = entry.changes.any? ? :update : :up_to_date
      end
      entry
    end
  end

  def entry_for(row, by_aai, seen, claimed)
    return Entry.new(row:, status: :problem, problem: row.problem) if row.problem
    if seen.include?(row.aai_number)
      return Entry.new(row:, status: :problem, problem: "This Reg Life ID is on the list twice")
    end
    return Entry.new(row:, person: by_aai[row.aai_number]) if by_aai[row.aai_number]

    candidates = Person.named(row.fullname).select { it.aai_number.nil? && claimed.exclude?(it.id) }
    chosen(row, candidates) || matched(row, candidates)
  end

  # What an admin chose for this row, if anything
  def chosen(row, candidates)
    case (choice = @choices[row.aai_number])
    when nil, "" then nil
    when NEW then Entry.new(row:, status: :new)
    when LEAVE_OUT then Entry.new(row:, status: :left_out, candidates:)
    else
      person = candidates.find { it.id.to_s == choice }
      Entry.new(row:, person:) if person
    end
  end

  # The one person with this name and year of birth (or none recorded), or
  # else a choice for an admin
  def matched(row, candidates)
    return Entry.new(row:, status: :new) if candidates.empty?

    same_year = candidates.select { it.birth_year.nil? || it.birth_year == row.year }
    return Entry.new(row:, person: same_year.first) if same_year.one?

    Entry.new(row:, status: :choose, candidates:)
  end

  def changes(person, row, members)
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

  def add(entry)
    row = entry.row
    person = Person.create!(firstname: Person.tidy_name(row.firstname), surname: Person.tidy_name(row.surname),
                            aai_number: row.aai_number, year: row.year.to_s, gender: row.gender)
    person.club_memberships.create!(year:)
  end

  def update(entry)
    row = entry.row
    person = entry.person
    person.aai_number ||= row.aai_number
    person.update!(year: row.year.to_s, gender: row.gender)
    person.club_memberships.find_or_create_by!(year:)
  end
end
