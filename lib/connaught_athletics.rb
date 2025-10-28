# frozen_string_literal: true

require "csv"
require "nokogiri"

module ConnaughtAthletics
  class Competition
    attr_reader :url

    def initialize(url:)
      @url = url
      @doc = Nokogiri::HTML(Typhoeus.get(url).body)
    end

    def events
      @doc.css(".button-container button").map do |b|
        event(name: b.content, url: b["onclick"][10..][..-3])
      end
    end

    def event(name:, url:)
      ConnaughtAthletics::Event.new(competition: self, name:, url:)
    end

    def name
      @doc.css("title").text
    end

    def slug
      I18n.transliterate(name)
          .gsub(/\s+/, "-")    # replace spaces with -
          .gsub(/[^\w]+/, "-") # replace all non-word chars with -
          .gsub(/--+/, "-")    # replace multiple - with single -
          .gsub(/^-/, "")      # remove leading -
          .gsub(/-$/, "")      # remove trailing -
          .downcase
    end

    def to_csv
      CSV.generate(+"", headers: %w[Place Name Club County], write_headers: true) do |csv|
        events.each do |event|
          event.results.each do |result|
            csv << [result.place, result.name, result.club, result.county]
          end
        end
      end
    end

    def save_results
      dbevent = ::Event.find_or_create_by(title: name) do |e|
        e.start_time = Time.zone.now
      end

      events.each do |e|
        race = dbevent.races.find_or_create_by(name: e.name) do |r|
          r.category = e.name
        end

        e.results.each do |r|
          race.results.find_or_create_by!(
            name: r.name,
            club: r.club,
            county: r.county,
            category: e.name,
            position: r.place
          )
        end
      end
    end
  end

  class Event
    attr_reader :competition, :name

    def initialize(competition:, name:, url:)
      @competition = competition
      @name = name
      @url = url
    end

    def results
      doc = Nokogiri::HTML(Typhoeus.get("#{@competition.url}#{@url}").body)
      out = doc.css(".individual-table tr").map do |r|
        place = r.at_xpath("td[1]/text()").to_s.strip
        name = r.at_xpath("td[3]/text()").to_s.strip
        club = r.at_xpath("td[4]/text()").to_s.strip
        county = r.at_xpath("td[5]/text()").to_s.strip

        result(place:, name:, club:, county:)
      end

      out.reject { |r| r.place == "" }
    end

    def result(place:, name:, club:, county:)
      ConnaughtAthletics::Result.new(
        event: self,
        place:,
        name:,
        club:,
        county:
      )
    end
  end

  class Result
    attr_reader :place, :name, :club, :county

    def initialize(event:, place:, name:, club:, county:)
      @event = event
      @place = place
      @name = name
      @club = club
      @county = county
    end
  end
end
