# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :race
  belongs_to :person, optional: true

  delegate :bib_numbers_included?, to: :race
  delegate :county_included?, to: :race
  delegate :timed?, to: :race

  scope :club_members, lambda {
    where(club: "Castlebar A.C.")
      .where.not("name LIKE ?", "%Relay%")
      .where.not("name LIKE ?", "Castlebar%")
  }
  scope :not_linked, -> { club_members.where(person_id: nil) }

  def h
    seconds.to_i / 3600
  end

  def m
    (seconds.to_i % 3600) / 60
  end

  def s
    seconds.to_i % 60
  end

  def ms
    seconds.to_s.match(/(\.\d+)/)&.captures&.first || ""
  end

  # e.g. 9.85, 6:12.0 or 1:02:05.4, or else what the results say, like a
  # distance jumped (stored as negative seconds) or DNF
  def net_time
    return result.to_s unless seconds.to_f.positive?

    if h.zero?
      hours = ""

      mins = m.zero? ? "" : "#{m}:"
    else
      hours = "#{h}:"
      mins = format("%02d:", m)
    end

    secs = mins.empty? ? s.to_s : format("%02d", s)

    "#{hours}#{mins}#{secs}#{ms[0..2]}"
  end

  def castlebarac?
    club == "Castlebar A.C."
  end

  # 1st to 3rd
  def medal?
    (1..3).cover?(position)
  end
end
