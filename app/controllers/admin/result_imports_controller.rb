# frozen_string_literal: true

module Admin
  # Imports results from another website in three steps: enter the address of
  # the results page (new), choose the event and races (preview), then import
  # them (create).
  class ResultImportsController < ApplicationController
    before_action :admin_only!
    before_action :load_source, except: :new

    rescue_from ResultSources::Error do |error|
      redirect_to new_admin_result_import_path(url: params[:url]), alert: error.message
    end

    def new
      @url = params[:url]
      @sites = ResultSources.supported_sites
    end

    def preview
      @races = @source.races
      raise ResultSources::Error, "There aren't any results on that page yet" if @races.empty?

      @matching_events = matching_events
      @new_event = Event.new(title: @source.title, start_time: @source.start_time, content: @source.event_content)
    end

    def create
      selections = selected_races
      if selections.empty?
        redirect_to preview_admin_result_imports_path(url: @source.url), alert: t(".choose_a_race")
        return
      end

      event = find_or_create_event
      return if event.nil?

      count = ResultImport.new(source: @source, event:, selections:).call
      linker = ResultLinker.new(Result.where(race: event.races.where(name: selections.map(&:name))))
      notice = t(".imported", count:, title: event.title) + t(".linked", count: linker.link_matches.size)

      if linker.unlinked.exists?
        redirect_to admin_event_unlinked_results_path(event), notice:, status: :see_other
      else
        redirect_to event_path(event), notice:, status: :see_other
      end
    end

    private

    def load_source
      @source = ResultSources.for(params.expect(:url))
    end

    # Events with the same title, or on the same day
    def matching_events
      events = Event.where("LOWER(title) = ?", @source.title.to_s.downcase)
      events = events.or(Event.where(start_time: @source.date.in_time_zone.all_day)) if @source.date
      events.order(start_time: :desc)
    end

    def find_or_create_event
      event_id = params.fetch(:event_id, "new")
      return Event.find(event_id) unless event_id == "new"

      event = Event.new(params.expect(event: %i[title start_time content]))
      return event if event.save

      redirect_to preview_admin_result_imports_path(url: @source.url),
                  alert: t(".event_invalid", errors: event.errors.full_messages.to_sentence)
      nil
    end

    def selected_races
      chosen = params.fetch(:races, {})
      @source.races.filter_map do |race|
        fields = chosen[race.key]
        next unless fields && fields[:import] == "1"

        ResultImport::Selection.new(
          key: race.key,
          name: fields[:name].presence || race.name,
          distance: fields[:distance].presence&.to_i
        )
      end
    end
  end
end
