# frozen_string_literal: true

module ResultSources
  # Connaught Athletics results that aren't on the newer /XC/ pages: track and
  # field competitions (ConnaughtTrack) and cross country from 2024 and 2025
  # (ConnaughtLegacyXc). Which one a page is can only be told by loading it.
  class ConnaughtPages < Base
    site "Connaught Athletics", hosts: ConnaughtXc.hosts

    def self.handles?(uri)
      super && !uri.path.start_with?("/XC/")
    end

    def self.build(uri)
      track = ConnaughtTrack.new(uri)
      return track if track.races.any?

      legacy = ConnaughtLegacyXc.new(uri)
      return legacy if legacy.races.any?

      raise Error, "Couldn't find any results on #{uri}"
    end
  end
end
