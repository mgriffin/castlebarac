# frozen_string_literal: true

module ResultSources
  # Results on myrunresults.com, used by Athletics Ireland for national cross
  # country championships, e.g.
  # https://myrunresults.com/events/123ie_national_uneven_xc_2025/6045/results
  class MyRunResults < Base
    site "MyRunResults", hosts: %w[myrunresults.com www.myrunresults.com]

    API = "https://api.myrunresults.com/api/PublicEvent"
    PAGE_SIZE = 500

    def initialize(uri)
      super
      @race_id = uri.path[%r{\A/events/[^/]+/(\d+)}, 1]
      raise Error, "That isn't a MyRunResults event page" if @race_id.nil?
    end

    def title
      info["raceName"].to_s.squish
    end

    def date
      start&.to_date
    end

    def start_time
      start || super
    end

    def start_time_known?
      start.present? && start.seconds_since_midnight.positive?
    end

    # One race for each class, e.g. "Girls U11"
    def races
      @races ||= Array(get_json("#{API}/GetTotalRunners", raceId: @race_id)["runnersByClasses"]).filter_map do |race|
        name = race["className"].to_s.squish
        Race.new(key: name, name:, selected: true) if name.present?
      end
    end

    def results_for(key)
      runners = []
      loop do
        page = post_json("#{API}/GetRunnersStatsAll", { option: { raceId: @race_id.to_i, runnerClass: key } },
                         toggle: 1, skipCount: runners.size, maxResultCount: PAGE_SIZE)
        items = Array(page["items"])
        runners.concat(items)
        break if items.empty? || runners.size >= page["totalCount"].to_i
      end

      runners.map { |runner| row(runner) }
    end

    private

    def info
      @info ||= get_json("#{API}/GetBaseEventInfoById", id: @race_id)
    end

    def start
      Time.zone.parse(info["raceScheduledStartDate"].to_s)
    rescue ArgumentError
      nil
    end

    def row(runner)
      dnf = runner["runnerIsDnf"]
      Row.new(
        position: dnf || runner["runner_Place"].to_i.zero? ? nil : runner["runner_Place"].to_s,
        name: [runner["runner_FirstName"], runner["runner_LastName"]].join(" ").squish,
        club: runner["runner_Club"],
        bib: runner["runner_BibNo"].to_s,
        time: dnf ? "DNF" : runner["runner_NetTime"]
      )
    end
  end
end
