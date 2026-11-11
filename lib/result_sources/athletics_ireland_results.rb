# frozen_string_literal: true

module ResultSources
  # Track and field results on results.athleticsireland.ie, e.g.
  # http://results.athleticsireland.ie/results_2026/07_11_out_juvenileday3/menu.html
  # Add ?date=2026-06-27 to select only that day's events when one results
  # page covers two days.
  class AthleticsIrelandResults < Base
    site "Athletics Ireland", hosts: %w[results.athleticsireland.ie]

    def title
      text(menu, "/competition/name")
    end

    def location
      text(menu, "/competition/location").presence
    end

    def date
      Date.parse(query_param(:date) || text(menu, "/competition/startdate").to_s)
    rescue Date::Error
      nil
    end

    def races
      @races ||= menu.xpath("/competition/events/event").filter_map { |event| race_from(event) }
    end

    def results_for(key)
      event = Nokogiri::XML(get("#{directory_url}#{key}_list.xml"))
      field = text(event, "/event/eventtype/fieldtype").present?
      round = event.xpath("/event/rounds/round").reverse.find { |r| r.at_xpath(".//participation/results/result") }
      return [] if round.nil?

      rows = round.xpath(".//participation").map { |participation| row(participation, field) }
      rows.sort_by { |row| row.position_number || Float::INFINITY }
    end

    private

    def menu
      @menu ||= Nokogiri::XML(get("#{directory_url}menu.xml"))
    end

    # The day of the event's last round, e.g. the final
    def event_date(event)
      Date.parse(event.xpath("rounds/round/datescheduled").last&.text.to_s)
    rescue Date::Error
      nil
    end

    def distance(event)
      type = event.at_xpath("eventtype")
      return if text(type, "fieldtype").present? || text(type, "athletesquantity").to_i > 1

      text(type, "distance").to_i.nonzero?
    end

    def race_from(event)
      key = text(event, "ID")
      name = text(event, "name")
      return if key.blank? || name.blank?

      day = event_date(event)
      Race.new(key:, name:, label: [name, day&.strftime("%a %-d %b")].compact.join(" – "),
               distance: distance(event), selected: query_param(:date).nil? || day == date)
    end

    def row(participation, field)
      relay = participation["relay"] == "true"
      competitor = participation.at_xpath(".//competitor")
      result = participation.at_xpath("results/result[@bestresult='1']") || participation.at_xpath("results/result")

      Row.new(
        position: (position(participation) if result),
        name: relay ? team_name(participation) : full_name(competitor&.at_xpath("athlete")),
        club: text(competitor, "team/name"),
        bib: (text(competitor, "bib") unless relay),
        time: text(result, "value"),
        field:
      )
    end

    # The place in the round, which is the place overall in a final
    def position(participation)
      place = text(participation, "currentorder_round").presence || text(participation, "currentorder")
      place if place.to_i.positive?
    end

    # "Clonliffe Harriers A.C.  (1350)" -> "Clonliffe Harriers A.C."
    def team_name(participation)
      text(participation, "teamname").to_s.sub(/\s*\(\d+\)\z/, "")
    end

    def text(node, xpath)
      node&.at_xpath(xpath)&.text.to_s.squish.presence
    end

    def full_name(athlete)
      return "" if athlete.nil?

      %w[firstname middlename lastname].filter_map { |part| text(athlete, part).presence }.join(" ")
    end
  end
end
