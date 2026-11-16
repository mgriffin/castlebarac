# frozen_string_literal: true

# Anyone can see competitions, except drafts, which only the people who
# manage competitions can see
class CompetitionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    !record.entries_draft? || Admin::CompetitionPolicy.new(user, record).show?
  end
end
