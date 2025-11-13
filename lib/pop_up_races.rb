# frozen_string_literal: true

require "json"

class PopUpRaces
  def self.save_from_json(event:, json:)
    results = JSON.parse(json)
    category = results["data"].keys.first[3..-9]

    race = event.races.find_or_create_by!(name: category)

    results["data"].values.first.each do |result|
      race.results.find_or_create_by!(
        name: result[3],
        club: result[4],
        result: result[5],
        seconds: time_in_seconds(result[5]),
        bib: result[0],
        category:,
        position: result[2]
      )
    end
  end

  def self.time_in_seconds(time)
    hours, minutes, seconds = time.split(":")

    ActiveSupport::Duration.parse("P0Y0M0DT#{hours}H#{minutes}M#{seconds}S").to_i
  end
end
