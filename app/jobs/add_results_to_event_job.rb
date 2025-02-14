class AddResultsToEventJob < ApplicationJob
  queue_as :default

  def perform(event_id:, races:)
    event = Event.find(event_id)

    races.each do |r|
      race_name = r["name"].strip.gsub(" - Results", "")
      race = event.races.find_or_create_by(name: race_name)

      return if r["participants"].nil?

      r["participants"].each do |p|
        race.results.find_or_create_by!(
          name: p["name"].strip,
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
