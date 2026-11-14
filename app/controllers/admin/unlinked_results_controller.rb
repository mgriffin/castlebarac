# frozen_string_literal: true

module Admin
  # Castlebar A.C. results on an event that aren't linked to anyone because
  # the athlete isn't on the site yet. Admins can add them and link them, like
  # the results:link rake task does.
  class UnlinkedResultsController < BaseController
    before_action :load_event

    def index
      @results = linker.unlinked.includes(:race).order("results.race_id", :position)
    end

    def create
      chosen = params.fetch(:people, {})
      created = linker.unlinked.where(id: chosen.keys).count do |result|
        fields = chosen[result.id.to_s]
        next false unless fields[:create] == "1" && fields[:firstname].present? && fields[:surname].present?

        ResultLinker.link_to_new_person(result, firstname: fields[:firstname].squish, surname: fields[:surname].squish)
      end

      redirect_to event_path(@event), notice: t(".linked", count: created), status: :see_other
    end

    private

    def load_event
      @event = Event.find_by!(url: params.expect(:event_id))
    end

    def linker
      ResultLinker.new(Result.where(race: @event.races))
    end
  end
end
