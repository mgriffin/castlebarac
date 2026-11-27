# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :race
  belongs_to :person, optional: true

  delegate :bib_numbers_included?, to: :race
  delegate :county_included?, to: :race
  delegate :timed?, to: :race

  # Nothing takes this long, so a time this big is a placeholder for no time
  MAX_SECONDS = 1.week.to_i

  # No place or time, rather than placeholders for them like 0
  normalizes :position, with: ->(position) { position if position.positive? }
  normalizes :seconds, with: ->(seconds) { seconds if seconds < MAX_SECONDS }

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
    return result.to_s unless time?

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

  # A time to show, rather than a mark (stored as negative seconds) or none
  def time?
    seconds.to_f.positive? && seconds < MAX_SECONDS
  end

  def placed?
    position.to_i.positive?
  end

  def castlebarac?
    club == "Castlebar A.C."
  end

  # 1st to 3rd
  def medal?
    (1..3).cover?(position)
  end
end
