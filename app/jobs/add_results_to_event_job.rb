# frozen_string_literal: true

class AddResultsToEventJob < ApplicationJob
  queue_as :default

  def perform(event:, url:)
    links = result_links_from(url)
    result_name = links.first.match(/(\w+)\.php/).captures.first

    ids_from(links).each do |id|
      doc = Nokogiri::HTML(Typhoeus.get("#{url}/#{result_name}.php", params: { id: id }).body)

      name = doc.css("title").text
                .gsub(" - Results", "")

      json = doc.css("script").text
                .strip
                .split("\n")
                .first

      next if json.nil?

      json = json.gsub(/^.*?{/, "{")
                 .gsub(/;const.*/, "")
                 .gsub(";", "")

      Rails.logger.debug json
      next if json.nil?

      results = JSON.parse(json)

      ### Don't create anything if there's no results
      next if results["1"]["allParticipants"].nil?

      Rails.logger.debug "got results"

      race = event.races.find_or_create_by(name: name)
      Rails.logger.debug race

      create_results(race, results["1"]["allParticipants"])
    end
  end

  def result_links_from(url)
    Nokogiri::HTML(Typhoeus.get("#{url}/competition.php").body)
            .css(".schedule-table tr")
            .collect { |tr| tr.attribute("onclick")&.value }
            .compact
  end

  def ids_from(links)
    links.map { |text| text.match(/\w+\.php\?id=(\d+)/).captures.first }
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
