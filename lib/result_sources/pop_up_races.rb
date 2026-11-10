# frozen_string_literal: true

module ResultSources
  # Race pages on popupraces.ie, e.g.
  # https://www.popupraces.ie/race/mayo-primary-schools-xc-2026/
  # A link to one results list (…/#1_7336A4) selects just that race.
  class PopUpRaces < Base
    site "Pop Up Races", hosts: %w[popupraces.ie www.popupraces.ie]

    DATE = /
      (?:(?:mon|tues|wednes|thurs|fri|satur|sun)day,?\s+)?(?:the\s+)?
      \b(\d{1,2})(?:st|nd|rd|th)?\s+(?:of\s+)?(#{Date::MONTHNAMES.compact.join('|')})\b(?:,?\s+(\d{4}))?
    /ix
    TIME = /(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)/i
    DISTANCE = /\A(\d+(?:\.\d+)?)\s*(m|metres?|meters?|km|k|miles?)\z/i

    def self.distance_in_metres(text)
      match = text.to_s.squish.match(DISTANCE)
      return if match.nil?

      number = BigDecimal(match[1])
      case match[2].downcase
      when "m", /\Amet/ then number
      when "km", "k" then number * 1000
      else number * 1609.344
      end.round
    end

    def title
      doc.at_css("h1.page-title")&.text&.squish.presence ||
        doc.at_css("title")&.text.to_s.sub(/\s*-\s*Pop Up Races\z/, "").squish
    end

    # The date is only in the race description, e.g.
    # "will take place in Belleek, Ballina, on Wednesday 23rd September" or
    # "hosting the Castlegar Open Cross Country on 19th September from 11.30am"
    def date
      return if date_match.nil?

      day, month, year = date_match.captures
      year ||= title[/\b(20\d{2})\b/, 1] || Time.zone.today.year
      Date.new(year.to_i, Date::MONTHNAMES.index(month.capitalize), day.to_i)
    rescue Date::Error
      nil
    end

    def start_time
      return super if date.nil? || first_start.nil?

      date.in_time_zone.change(first_start)
    end

    def start_time_known?
      first_start.present?
    end

    def races
      @races ||= race_result.lists.map do |list|
        Race.new(
          key: list.id,
          name: list.contest_name || list.label,
          label: list.label,
          distance: schedule.find { |row| row[:race].casecmp?(list.contest_name.to_s) }&.dig(:distance),
          selected: list_id ? list.id == list_id : list.full_results?
        )
      end
    end

    def results_for(key)
      list = race_result.lists.find { |l| l.id == key }
      raise Error, "There's no results list #{key} on #{url}" if list.nil?

      race_result.results(list)
    end

    private

    def doc
      @doc ||= get_html(page_url)
    end

    def details
      doc.at_css("#details") || doc
    end

    # "7336A4" from "#1_7336A4"
    def list_id
      uri.fragment.to_s.split("_").last.presence
    end

    def race_result
      @race_result ||= begin
        id = doc.css("script").text[/new RRPublish\([^,]+,\s*(\d+)/, 1]
        raise Error, "There aren't any results on #{url} yet" if id.nil?

        RaceResult.new(id, fetcher: ->(url, **params) { get_json(url, **params) })
      end
    end

    # The "Event Order" table: | 11:00am | 3rd & 4th Class Girls | 1000m |
    def schedule
      @schedule ||= details.css("table tr").filter_map do |tr|
        cells = tr.css("td").map { |td| td.text.squish }
        schedule_row(cells) if cells.any?
      end
    end

    def schedule_row(cells)
      distance = cells.find { |cell| self.class.distance_in_metres(cell) }
      {
        race: (cells - [cells.first, distance]).first.to_s,
        distance: self.class.distance_in_metres(distance),
        start: start_from(cells.first.match(TIME))
      }
    end

    # { hour:, min: } from a "11:15am" match
    def start_from(time)
      return if time.nil?

      hour = time[1].to_i % 12
      hour += 12 if time[3].casecmp?("pm")
      { hour:, min: time[2].to_i }
    end

    # From the "Event Order" table, or else a time just after the date
    def first_start
      schedule.filter_map { |row| row[:start] }.first ||
        (date_match && start_from(date_match.post_match[0, 30].match(TIME)))
    end

    def date_match
      return @date_match if defined?(@date_match)

      @date_match = details.text.squish.match(DATE)
    end
  end
end
