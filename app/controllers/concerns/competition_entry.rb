# frozen_string_literal: true

# Finds the competition and the signed in user's entry into it
module CompetitionEntry
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_competition_and_entry

    rescue_from Payment::InProgress do
      redirect_to competition_entry_path(@competition), alert: t("competitions.payment_in_progress")
    end
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

  # The user and their children. Staff can enter anyone, but everyone else
  # can only enter these people.
  def linked_people
    person = current_user.person
    return [] if person.nil?

    [person, *person.children.order(:firstname)]
  end

  def set_athlete
    @athlete = find_athlete(params.expect(params.key?(:athlete_id) ? :athlete_id : :id))
  end

  # Someone the user can enter, or not found
  def find_athlete(id)
    return Person.find(id) if policy(@entry).enter_anyone?

    linked_people.find { it.id.to_s == id.to_s } || raise(ActiveRecord::RecordNotFound)
  end
end
