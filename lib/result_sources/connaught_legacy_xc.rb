# frozen_string_literal: true

module ResultSources
  # Cross country results on connaughtathletics.com from 2024 and 2025, with
  # a button for each race, e.g.
  # https://connaughtathletics.com/2024/connacht/xc/unevens/
  class ConnaughtLegacyXc < Base
    site "Connaught Athletics", hosts: ConnaughtXc.hosts

    COLUMNS = { position: /\Apos/i, name: /\Aname/i, club: /\Aclub/i, county: /\Acounty/i }.freeze

    def title
      doc.at_css("title")&.text&.squish.presence || doc.at_css(".banner h3")&.text&.squish
    end

    # These pages don't give the date
    def date
      nil
    end

    def races
      @races ||= doc.css(".button-container button[onclick]").filter_map do |button|
        key = button["onclick"][/loadPage\('([^']+)'\)/, 1]
        next if key.blank? || key.start_with?("entries")

        name = button["aria-label"].to_s.sub(/\ALoad results for\s*/i, "").squish.presence || button.text.squish
        Race.new(key:, name:, selected: true)
      end
    rescue Error
      @races = []
    end

    def results_for(key)
      header, *rows = individual_results(key)
      return [] if header.nil?

      columns = COLUMNS.transform_values { |pattern| header.index { |cell| cell.match?(pattern) } }
      rows.filter_map do |cells|
        fields = columns.transform_values { |index| index && cells[index] }
        Row.new(**fields) if fields[:name].present?
      end
    end

    private

    # The cells of each row of the individual results table, header first.
    # The page also has team and county tables.
    def individual_results(key)
      table = get_html("#{directory_url}#{key}").css("table").find { |t| t["class"].to_s.include?("individual") }
      table ? table.css("tr").map { |tr| tr.css("th, td").map { |cell| cell.text.squish } } : []
    end

    def doc
      @doc ||= get_html(url)
    end
  end
end
