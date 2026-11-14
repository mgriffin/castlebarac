# frozen_string_literal: true

module Admin
  module People
    # Links a person to someone's account, or unlinks it, from the person's
    # edit page. People are never linked to accounts by name, as anyone can
    # type a name, so this is how someone gets their existing person.
    class AccountsController < BaseController
      before_action :set_person

      def create
        user = User.find_by(email: params.expect(:email).to_s.strip.downcase)
        return redirect_back_to_person(alert: t(".no_account")) if user.nil?

        AccountLinker.link!(@person, user)
        redirect_back_to_person(notice: t(".linked", email: user.email, name: @person.fullname))
      rescue ActiveRecord::RecordInvalid => e
        redirect_back_to_person(alert: e.record.errors.full_messages.to_sentence)
      end

      def destroy
        email = @person.user&.email
        @person.update!(user: nil)
        redirect_back_to_person(notice: email && t(".unlinked", email:, name: @person.fullname))
      end

      private

      def set_person
        @person = Person.find_by!(slug: params.expect(:person_id))
      end

      def redirect_back_to_person(notice: nil, alert: nil)
        redirect_to edit_admin_person_path(@person), notice:, alert:, status: :see_other
      end
    end
  end
end
