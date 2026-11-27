# frozen_string_literal: true

require "csv"

module Admin
  module Competitions
    # Everyone entered into a competition, to send on to the organisers. Only
    # paid entries count.
    class EntriesController < BaseController
      def index
        authorize [:admin, @competition], :entries?

        @entry_lines = @competition.entry_lines
                                   .includes(:person, :competition_event, :payment,
                                             confirmed_by: :person, entry: { user: :person })
                                   .reorder("competition_events.position, competition_events.id, people.surname")
                                   .references(:competition_events, :people)

        respond_to do |format|
          format.html
          format.csv do
            send_data to_csv(@entry_lines.paid), filename: "#{@competition.slug}-entries.csv", type: "text/csv"
          end
        end
      end

      private

      # Users without a person only have their email
      def user_name(user)
        user && (user.name || user.email)
      end
      helper_method :user_name

      def coach_ok(line)
        if line.confirmed?
          "#{user_name(line.confirmed_by)} #{l(line.confirmed_at, format: :short)}"
        elsif line.awaiting_confirmation?
          "Not confirmed"
        end
      end

      def to_csv(entry_lines)
        CSV.generate do |csv|
          csv << ["Event", "First name", "Surname", "Gender", "Year of birth", "Entered by", "Coach's OK"]
          entry_lines.each do |line|
            csv << [line.competition_event.name, line.person.firstname, line.person.surname,
                    line.person.gender, line.person.year, user_name(line.entry.user), coach_ok(line)]
          end
        end
      end
    end
  end
end
