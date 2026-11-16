# frozen_string_literal: true

# Anyone can see a competition, except a draft, which only the people who
# manage competitions can see
class CompetitionPolicy < ApplicationPolicy
  def show?
    !record.entries_draft? || Admin::CompetitionPolicy.new(user, record).show?
  end
end
