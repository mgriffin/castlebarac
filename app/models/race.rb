# frozen_string_literal: true

class Race < ApplicationRecord
  belongs_to :event
  has_many :results, dependent: :destroy

  def bib_numbers_included?
    results&.first&.bib.present?
  end

  def county_included?
    results&.first&.county.present?
  end

  def timed?
    results&.first&.seconds.nil?
  end
end
