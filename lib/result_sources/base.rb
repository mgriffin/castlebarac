# frozen_string_literal: true

require "nokogiri"

module ResultSources
  # Each results site subclasses this and implements title, date, races and
  # results_for. start_time, location and distances are optional.
  class Base
    class << self
      attr_reader :site_name, :hosts

      def site(name, hosts:)
        @site_name = name
        @hosts = hosts
      end

      def handles?(uri)
        hosts.include?(uri.host.to_s.downcase)
      end

      # The reader for this URL. Sites with more than one kind of results page
      # override this to pick the right reader.
      def build(uri)
        new(uri)
      end
    end

    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def url
      uri.to_s
    end

    delegate :site_name, to: :class

    def title
      raise NotImplementedError
    end

    def date
      raise NotImplementedError
    end

    # Override when the page says when the first race starts
    def start_time
      date&.in_time_zone
    end

    def start_time_known?
      false
    end

    def location
      nil
    end

    def races
      raise NotImplementedError
    end

    def race(key)
      races.find { |race| race.key == key }
    end

    # [Row, ...] for the race with this key
    def results_for(_key)
      raise NotImplementedError
    end

    # A description for an event created from this page
    def event_content
      link = ActionController::Base.helpers.link_to(site_name, url)
      [location && "<p>#{ERB::Util.html_escape(location)}</p>", "<p>Results from #{link}</p>"].compact.join
    end

    private

    def get(url, **params)
      response = Typhoeus.get(url, params:, followlocation: true)
      return response.body if response.success?

      reason = response.code.zero? ? response.return_message : "HTTP #{response.code}"
      raise Error, "Couldn't load #{url} (#{reason})"
    end

    # The directory of the page in the URL, e.g. https://example.com/a/b/
    # for https://example.com/a/b/menu.html or https://example.com/a/b
    def directory_url
      path = uri.path.sub(%r{/[^/]*\.(?:html?|php|xml)\z}i, "/")
      path += "/" unless path.end_with?("/")
      "#{uri.scheme}://#{uri.host}#{path}"
    end

    def query_param(name)
      URI.decode_www_form(uri.query.to_s).to_h[name.to_s].presence
    end

    def get_html(url)
      Nokogiri::HTML(get(url))
    end

    def get_json(url, **params)
      JSON.parse(get(url, **params))
    rescue JSON::ParserError
      raise Error, "#{url} didn't return any results"
    end

    def page_url
      uri.dup.tap { |u| u.fragment = nil }.to_s
    end
  end
end
