# frozen_string_literal: true

# What competitions need to know about a person: their entries, and the
# year of birth and gender that decide which events they can enter
module Competitor
  extend ActiveSupport::Concern

  GENDERS = %w[female male].freeze

  included do
    has_many :entry_lines, dependent: :restrict_with_error

    # Asked for the first time someone is entered into a competition
    with_options on: :entry_details do
      validates :gender, inclusion: { in: GENDERS }
      validates :year, format: { with: /\A(19|20)\d\d\z/ }
    end
  end

  def birth_year
    year.to_i if year.to_s.match?(/\A\d{4}\z/)
  end

  # Age on the given date, going by birth year only
  def age_on(date)
    date.year - birth_year
  end

  def entry_details_complete?
    birth_year.present? && GENDERS.include?(gender)
  end
end
