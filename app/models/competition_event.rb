# frozen_string_literal: true

class CompetitionEvent < ApplicationRecord
  GENDERS = %w[female male].freeze

  belongs_to :competition
  has_many :entry_lines, dependent: :restrict_with_error

  validates :name, presence: true
  validates :gender, inclusion: { in: GENDERS }, allow_blank: true
  validates :min_age, :max_age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :age_range_in_order

  before_validation :ages_from_age_group
  before_validation { self.gender = gender.presence }

  def eligible?(person)
    ineligibility_reason(person).nil?
  end

  # Why the person can't enter, or nil if they can
  def ineligibility_reason(person)
    return :missing_details unless person.entry_details_complete?
    return :gender if gender.present? && person.gender != gender

    age_reason(person.age_on(competition.age_reference_date))
  end

  private

  def age_reason(age)
    return :too_young if min_age && age < min_age

    :too_old if max_age && age > max_age
  end

  # "U12" means the athlete is 11 on 31 December, unless the ages are given
  def ages_from_age_group
    return if min_age.present? || max_age.present?

    under = age_group.to_s[/\AU(\d+)\z/i, 1]
    return unless under

    self.min_age = self.max_age = under.to_i - 1
  end

  def age_range_in_order
    return if min_age.blank? || max_age.blank? || min_age <= max_age

    errors.add(:max_age, :less_than_min_age)
  end
end
