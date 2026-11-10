# frozen_string_literal: true

module ResultSources
  # Client for the public API behind RaceResult's "RRPublish" results widget,
  # which sites like popupraces.ie embed.
  class RaceResult
    HOST = "https://my.raceresult.com"

    List = Struct.new(:id, :name, :contest_id, :contest_name, keyword_init: true) do
      # "Result Lists|Full Results" -> "Full Results"
      def short_name
        name.to_s.split("|").last
      end

      def full_results?
        short_name.match?(/full results/i)
      end

      def label
        [contest_name, short_name].compact_blank.join(" – ")
      end
    end

    def initialize(event_id, fetcher:)
      @event_id = event_id
      @fetcher = fetcher
    end

    # Lists of individual results shown on the results page
    def lists
      @lists ||= (config.dig("TabConfig", "Lists") || [])
                 .reject { |list| list["Mode"] == "hidden" || team_results?(list["Name"]) }
                 .uniq { |list| list["ID"] }
                 .map do |list|
                   List.new(id: list["ID"], name: list["Name"], contest_id: list["Contest"],
                            contest_name: config.dig("contests", list["Contest"].to_s))
                 end
    end

    def results(list)
      json = @fetcher.call(
        "https://#{config['server'].presence || URI(HOST).host}/#{@event_id}/results/list",
        key: config["key"], listname: list.name, page: "results", contest: list.contest_id, r: "all", l: 0
      )
      columns = columns(json)
      raise Error, "Couldn't find the names in #{list.label}" if columns[:name].nil?

      rows(json["data"]).filter_map do |row|
        Row.new(**columns.transform_values { |i| i && row[i].to_s.strip }) if row[columns[:name]].present?
      end
    end

    private

    # "Result Lists|Team Results Girls", but not "Full Results - Teams Here"
    def team_results?(name)
      name.to_s.split("|").last.to_s.match?(/\Ateam/i)
    end

    def config
      @config ||= @fetcher.call("#{HOST}/#{@event_id}/results/config", lang: "en", page: "results", noVisitor: 1)
    end

    # Which position in each data row holds which value, worked out from the
    # column headings on the results page
    def columns(json)
      data_fields = json["DataFields"] || []
      fields = json.dig("list", "Fields") || []
      index_of = lambda do |pattern|
        field = fields.find { |f| f["Label"].to_s.match?(pattern) }
        field && data_fields.index(field["Expression"])
      end

      {
        position: index_of.call(/\A(pos|place|rank)/i),
        name: index_of.call(/name/i),
        club: index_of.call(/club|school|team/i),
        bib: index_of.call(/\Abib/i),
        time: index_of.call(/chip/i) || index_of.call(/time|finish/i)
      }
    end

    # Rows are grouped under keys like "#1_3rd & 4th Class Girls", and groups
    # can be nested, so collect rows at any depth
    def rows(data)
      case data
      when Hash then data.values.flat_map { |value| rows(value) }
      when Array then data.first.is_a?(Array) ? data : data.flat_map { |value| rows(value) }
      else []
      end
    end
  end
end
