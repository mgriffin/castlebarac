# frozen_string_literal: true

class Race < ApplicationRecord
  belongs_to :event
  has_many :results, dependent: :destroy

  # Counted in Ruby so the results the event page has already loaded are
  # used, and kept because the page asks for it more than once
  def club_result_count
    @club_result_count ||= results.count(&:castlebarac?)
  end

  def bib_numbers_included?
    results&.first&.bib.present?
  end

  def county_included?
    results&.first&.county.present?
  end

  # Times, or marks for field events, rather than only places
  def times_included?
    results&.first&.seconds.present?
  end
end
