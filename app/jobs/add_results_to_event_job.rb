# frozen_string_literal: true

class AddResultsToEventJob < ApplicationJob
  queue_as :default

  def perform(event:, url:)
    result_ids_from(url).each do |id|
      doc = Nokogiri::HTML(Typhoeus.get("#{url}/results.php", params: { id: id }).body)

      name = doc.css("title").text
                .gsub(" - Results", "")

      json = doc.css("script").text
                .strip
                .split("\n")
                .first
                &.gsub(/^.*?{/, "{")
                &.gsub(";", "")

      next if json.nil?

      results = JSON.parse(json)

      ### Don't create anything if there's no results
      next if results["1"]["allParticipants"].nil?

      race = event.races.find_or_create_by(name: name)

      create_results(race, results["1"]["allParticipants"])
    end
  end

  def result_ids_from(url)
    Nokogiri::HTML(Typhoeus.get("#{url}/competition.php").body)
            .css(".schedule-table tr")
            .collect { |tr| tr.attribute("onclick")&.value }
            .compact.map { |text| text.match(/results\.php\?id=(\d+)/).captures.first }
  end

  def create_results(race, participants)
    participants.each do |p|
      name = p["isRelay"] ? p["teamName"].strip : p["name"].strip

      race.results.find_or_create_by!(
        name: name,
        club: p["club"],
        result: p["result"],
        seconds: p["sortValue"],
        heat: p["heatNumber"],
        bib: p["bib"],
        category: p["categoryAbbr"],
        position: p["displayPosition"]
      )
    end
  end
end
