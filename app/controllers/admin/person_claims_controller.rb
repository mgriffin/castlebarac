# frozen_string_literal: true

module Admin
  # Claims to be an existing person, made from the profile form, for admins
  # to approve or reject
  class PersonClaimsController < BaseController
    def index
      @pending = PersonClaim.pending.includes(:user, person: :teams).order(:created_at)
      @reviewed = PersonClaim.where.not(status: :pending).includes(:user, :person, :reviewed_by)
                             .order(reviewed_at: :desc).limit(20)
    end

    def approve
      claim = PersonClaim.pending.find(params.expect(:id))
      claim.approve!(current_user)
      redirect_to admin_person_claims_path, status: :see_other,
                                            notice: t(".approved", email: claim.user.email, name: claim.person.fullname)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_person_claims_path, status: :see_other, alert: e.record.errors.full_messages.to_sentence
    end

    def reject
      claim = PersonClaim.pending.find(params.expect(:id))
      claim.reject!(current_user)
      redirect_to admin_person_claims_path, status: :see_other,
                                            notice: t(".rejected", email: claim.user.email, name: claim.person.fullname)
    end
  end
end
