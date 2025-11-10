# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :race
  belongs_to :person, optional: true

  delegate :bib_numbers_included?, to: :race
  delegate :county_included?, to: :race
  delegate :timed?, to: :race

  scope :club_members, -> { where(club: "Castlebar A.C.").where.not("name LIKE ?", "%Relay%") }
  scope :not_linked, -> { club_members.where(person_id: nil)}

  def net_time
    h = seconds.to_i / 3600
    m = (seconds.to_i % 3600) / 60
    s = seconds.to_i % 60
    ms = seconds.to_s.match(/(\.\d+)/)&.captures&.first || ""

    if h.zero?
      h = ""

      m = m.zero? ? "" : "#{m}:"
    else
      h = "#{h}:"
      m = format("%02d:", m)
    end

    s = format("%02d", s) unless m == ""

    "#{h}#{m}#{s}#{ms[0..2]}"
  end

  def castlebarac?
    club == "Castlebar A.C."
  end
end
