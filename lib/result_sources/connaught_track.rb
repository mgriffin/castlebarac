# frozen_string_literal: true

module ResultSources
  # Track and field results on connaughtathletics.com, e.g.
  # https://connaughtathletics.com/2026/conninday3/competition.php
  # A link to one event (…/competition.php?id=777) selects just that event.
  class ConnaughtTrack < Base
    site "Connaught Athletics", hosts: ConnaughtXc.hosts

    def title
      doc.at_css(".event-header h1")&.text&.squish.presence || doc.at_css("title")&.text&.squish
    end

    def location
      doc.at_css(".event-info")&.text&.squish.presence
    end

    # The schedule doesn't give the date, so it comes from the first event
    def date
      Date.parse(first_round["datescheduled"].to_s)
    rescue Date::Error
      nil
    end

    def start_time
      time = first_round["scheduled"].to_s.match(/\A(\d{1,2}):(\d{2})/)
      return super if date.nil? || time.nil?

      date.in_time_zone.change(hour: time[1].to_i, min: time[2].to_i)
    end

    def start_time_known?
      first_round["scheduled"].present?
    end

    def races
      @races ||= doc.css("table.schedule-table tr[onclick]").filter_map { |row| race_from(row) }
    rescue Error
      @races = []
    end

    def results_for(key)
      page = event_page(key)
      round = page[:rounds].values.reverse.find { |r| r["allParticipants"].present? }
      return [] if round.nil?

      round["allParticipants"].map do |result|
        Row.new(
          position: result["displayPosition"].to_i.positive? ? result["displayPosition"].to_s : nil,
          name: (page[:relay] ? result["teamName"] : result["name"]).to_s.squish,
          club: result["club"],
          bib: result["bib"].to_s,
          time: result["result"],
          field: page[:field]
        )
      end
    end

    private

    def doc
      @doc ||= get_html("#{directory_url}competition.php")
    end

    def race_from(row)
      key = row["onclick"].to_s[/id=(\d+)/, 1]
      name = row.at_css("td")&.text&.squish
      Race.new(key:, name:, distance: distance(name), selected: selected?(key, row)) if key.present? && name.present?
    end

    def selected?(key, row)
      return query_param(:id) == key if query_param(:id)

      row["class"].to_s.include?("completed")
    end

    # "U9 Boys 60m" -> 60, but not relays like "4x100m"
    def distance(name)
      name[/(?<![x\d])(\d{2,5})m\b/i, 1]&.to_i
    end

    def first_round
      key = races.find(&:selected)&.key || races.first&.key
      key ? event_page(key)[:rounds].values.first || {} : {}
    end

    # The results are in a script on each event's page:
    # const roundData = {"1":{"name":"*","allParticipants":[…],…}};
    def event_page(key)
      @event_pages ||= {}
      @event_pages[key] ||= begin
        html = get("#{directory_url}competition.php?id=#{key}")
        json = html[%r{const roundData = (\{.*?\});\s*(?:const|let|var|</script>)}m, 1]
        raise Error, "Couldn't find the results for event #{key}" if json.nil?

        { rounds: JSON.parse(json), relay: flag?(html, "isRelayEvent"), field: flag?(html, "isFieldEvent") }
      end
    end

    def flag?(html, name)
      html.match?(/const #{name} = true/)
    end
  end
end
