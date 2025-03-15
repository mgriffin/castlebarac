# frozen_string_literal: true

class AddResultsToEventJob < ApplicationJob
  queue_as :default

  def perform(event:, url:)

    result_ids = Nokogiri::HTML(Typhoeus.get("#{url}/competition.php").body)
      .css(".schedule-table tr")
      .collect { |tr| tr.attribute("onclick")&.value }
      .compact.map { |text| text.match(%r{results\.php\?id=(\d+)}).captures.first }

    result_ids.each do |id|
      doc = Nokogiri::HTML(Typhoeus.get("#{url}/results.php", params: {id: id}).body)

      name = doc.css("title").text
        .gsub(/ - Results/, "")

      json = doc.css("script").text
        .strip
        .split("\n")
        .first
        &.gsub(/^.*?{/, "{")
        &.gsub(/;/, "")

      next if json.nil?
      results = JSON.parse(json)

      ### Don't create anything if there's no results
      next if results["1"]["allParticipants"].nil?

      race_name = results["1"]["name"].strip.gsub(" - Results", "")

      ### In the JSON, the race name is often not included, and
      ### instead there's an asterisk. If that happens, change it
      race_name = name if race_name == "*"
      race = event.races.find_or_create_by(name: race_name)

      results["1"]["allParticipants"].each do |p|
        name = if p.dig("isRelay")
                 p["teamName"].strip
               else
                 p["name"].strip
               end
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
end
