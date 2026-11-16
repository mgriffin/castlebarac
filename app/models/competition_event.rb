# frozen_string_literal: true

class CompetitionEvent < ApplicationRecord
  GENDERS = %w[female male].freeze

  belongs_to :competition

  validates :name, presence: true
  validates :gender, inclusion: { in: GENDERS }, allow_blank: true
  validates :min_age, :max_age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :age_range_in_order

  before_validation :ages_from_age_group
  before_validation { self.gender = gender.presence }

  def earliest_birth_year
    competition.age_reference_date.year - max_age if max_age
  end

  def latest_birth_year
    competition.age_reference_date.year - min_age if min_age
  end

  private

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
