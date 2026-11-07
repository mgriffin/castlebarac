# frozen_string_literal: true

# Reads results from other timing and results websites so they can be
# imported. ResultSources.for(url) picks the right reader for a URL.
module ResultSources
  class Error < StandardError; end

  # A race listed on a results page. `key` identifies it within the page and
  # `label` describes it when choosing what to import.
  Race = Struct.new(:key, :name, :label, :distance, :selected, keyword_init: true) do
    def label
      self[:label].presence || name
    end
  end

  # One person's result in a race
  Row = Struct.new(:position, :name, :club, :bib, :time, keyword_init: true) do
    def position_number
      position.to_s[/\A\d+/]&.to_i
    end

    def bib_number
      bib.to_s[/\A\d+\z/]&.to_i
    end

    # "0:03:59", "3:59" or "45.63" in seconds; nil for "DNF" and the like
    def seconds
      return unless time.to_s.strip.match?(/\A\d+(:\d{1,2}){0,2}(\.\d+)?\z/)

      time.strip.split(":").reduce(0) { |total, part| (total * 60) + BigDecimal(part) }
    end
  end

  def self.sources
    [PopUpRaces, ConnaughtXc]
  end

  def self.for(url)
    uri = URI.parse(url.to_s.strip)
    raise Error, "Enter the web address of a results page" unless uri.is_a?(URI::HTTP) && uri.host

    source = sources.find { |s| s.handles?(uri) }
    raise Error, "Can't import results from #{uri.host} yet. Try #{supported_sites}." if source.nil?

    source.new(uri)
  rescue URI::InvalidURIError
    raise Error, "Enter the web address of a results page"
  end

  def self.supported_sites
    sources.map(&:site_name).to_sentence(two_words_connector: " or ", last_word_connector: ", or ")
  end
end
