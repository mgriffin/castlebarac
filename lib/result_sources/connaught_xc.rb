# frozen_string_literal: true

module ResultSources
  # Cross country results on connaughtathletics.com, e.g.
  # https://connaughtathletics.com/XC/mayo-xc-uneven-ages-2026
  # A link to one race (…/XC/mayo-xc-uneven-ages-2026/u9-girls) works too.
  class ConnaughtXc < Base
    site "Connaught Athletics", hosts: %w[connaughtathletics.com www.connaughtathletics.com]

    FIELD_CLASSES = { position: "pos", name: "name", bib: "bib", time: "time", county: "county" }.freeze
    PATH = %r{\A/XC/(?<competition>[\w-]+)(?:/(?<race>[\w-]+))?/?\z}

    def initialize(uri)
      super
      @path = uri.path.match(PATH)
      raise Error, "That isn't a Connaught Athletics cross country results page" if @path.nil?
    end

    def title
      doc.at_css(".page-head h1")&.text&.squish.presence ||
        doc.at_css("title")&.text.to_s.sub(/\s*—.*\z/, "").squish
    end

    # From the line under the title, e.g. "11 October 2026 · Swinford"
    def date
      Date.parse(details.first.to_s)
    rescue Date::Error
      nil
    end

    def location
      details.second.presence
    end

    def races
      @races ||= doc.css("a.pick-row").filter_map do |link|
        key = link["href"].to_s.split("/").last
        name = text(link, ".pick-title")
        Race.new(key:, name:, selected: selected?(key)) if key.present? && name.present?
      end
    end

    def results_for(key)
      get_html("#{competition_url}/#{key}").css("ol.results-list li.result-row").map do |li|
        Row.new(club: club(li), **FIELD_CLASSES.transform_values { |css_class| text(li, ".#{css_class}") })
      end
    end

    private

    # Every race, unless the link was to one race
    def selected?(key)
      @path[:race].nil? || @path[:race] == key
    end

    # Regional competitions put the county inside the club, e.g.
    # <span class="club">Castlebar AC<span class="county">Mayo</span></span>
    def club(result)
      club = result.at_css(".club")
      club.xpath("text()").text.squish.presence if club
    end

    def text(node, selector)
      node.at_css(selector)&.text&.squish
    end

    def competition_url
      "https://#{uri.host}/XC/#{@path[:competition]}"
    end

    def doc
      @doc ||= get_html(competition_url)
    end

    def details
      @details ||= doc.at_css(".page-head .sub")&.text.to_s.split("·").map(&:squish)
    end
  end
end
