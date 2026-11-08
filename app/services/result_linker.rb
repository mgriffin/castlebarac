# frozen_string_literal: true

# Links Castlebar A.C. results to the people they belong to. Used by the
# results:link rake task and when importing results.
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
  # not on the site yet
  def self.link_to_new_person(result, firstname:, surname:)
    person = Person.match("#{firstname} #{surname}") || Person.create!(firstname:, surname:)
    result.update!(person:)
    person
  end
end
