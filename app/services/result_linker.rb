# frozen_string_literal: true

# Links Castlebar A.C. results to the people they belong to. Used when
# importing results, loading member lists and on the unlinked results page.
class ResultLinker
  attr_reader :results

  # results: the results to look through, e.g. an event's results
  def initialize(results = Result.all)
    @results = results
  end

  # Our club's results that aren't linked to anyone yet
  def unlinked
    results.not_linked
  end

  # Links each unlinked result to the person with the same name, if there is
  # one. Returns the results that were linked.
  def link_matches
    unlinked.includes(:race).select do |result|
      person = Person.match(result.name)
      person && result.update!(person:)
    end
  end

  # Links the result to the person with this name, creating them if they're
  # not on the site yet. If more than one person has the name, it links
  # nothing and returns nil, so that an admin can choose.
  def self.link_to_new_person(result, firstname:, surname:)
    people = Person.named("#{firstname} #{surname}")
    return if people.many?

    person = people.first || Person.create!(firstname:, surname:)
    result.update!(person:)
    person
  end
end
