# frozen_string_literal: true

# Finds the competition and the signed in user's entry into it
module CompetitionEntry
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_competition_and_entry
  end

  private

  def set_competition_and_entry
    @competition = Competition.friendly.find(params.expect(:competition_id))
    @entry = current_user.entries.find_or_initialize_by(competition: @competition)
  end

  def require_accepting_entries
    return if @competition.accepting_entries?

    redirect_to competition_entry_path(@competition), alert: t("competitions.entries_closed")
  end

  def set_athlete
    @athlete = Person.find(params.expect(params.key?(:athlete_id) ? :athlete_id : :id))
  end
end
