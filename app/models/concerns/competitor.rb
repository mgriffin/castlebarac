# frozen_string_literal: true

# What competitions need to know about a person: their entries, and the
# year of birth and gender that decide which events they can enter
module Competitor
  extend ActiveSupport::Concern

  GENDERS = %w[female male].freeze

  # From this age on, athletes are seniors
  SENIOR_AGE = 20

  # Years of birth that look right, e.g. 2015, for SQL
  BIRTH_YEAR_GLOB = "[12][0-9][0-9][0-9]"

  included do
    has_many :entry_lines, dependent: :restrict_with_error

    # Everyone who isn't a senior, including people whose age we don't know
    scope :juniors, lambda {
      where("people.year IS NULL OR NOT people.year GLOB :glob OR CAST(people.year AS INTEGER) > :year",
            glob: BIRTH_YEAR_GLOB, year: Date.current.year - SENIOR_AGE)
    }
    scope :without_birth_year, -> { where.not("people.year GLOB ?", BIRTH_YEAR_GLOB).or(where(year: nil)) }

    normalizes :year, :gender, with: -> { it.strip.presence }

    # When admins edit someone, these can be left blank
    with_options on: :birth_year do
      validates :gender, inclusion: { in: GENDERS }, allow_nil: true
      validates :year, format: { with: /\A(19|20)\d\d\z/ }, allow_nil: true
    end

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

  # Athletics Ireland age groups go by age on 31 December, so someone born
  # in 2015 is U12 for all of 2026. Nil if we don't know their year of birth.
  def age_group(on: Date.current)
    return if birth_year.nil?

    age = age_on(on)
    age >= SENIOR_AGE ? "Senior" : "U#{age + 1}"
  end

  def entry_details_complete?
    birth_year.present? && GENDERS.include?(gender)
  end
end
