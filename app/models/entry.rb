# frozen_string_literal: true

# Everything one user has entered into a competition
class Entry < ApplicationRecord
  belongs_to :competition
  belongs_to :user
  has_many :entry_lines, -> { includes(:competition_event).order(:id) },
           dependent: :destroy,
           inverse_of: :entry
  has_many :people, -> { distinct }, through: :entry_lines

  validates :user_id, uniqueness: { scope: :competition_id }

  delegate :accepting_entries?, to: :competition

  # { person => [entry lines] }
  def lines_by_person
    entry_lines.includes(:person).group_by(&:person)
  end
end
