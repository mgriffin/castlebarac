# frozen_string_literal: true

module Admin
  # Parents asking to be linked to their children, for admins to approve or
  # reject
  class ChildClaimsController < BaseController
    def index
      @pending = ChildClaim.pending.includes(user: :person, child: :parents).order(:created_at)
      @reviewed = ChildClaim.where.not(status: :pending).includes(:child, :reviewed_by, user: :person)
                            .order(reviewed_at: :desc).limit(20)
    end

    def approve
      claim = ChildClaim.pending.find(params.expect(:id))
      claim.approve!(current_user)
      redirect_to admin_child_claims_path, status: :see_other,
                                           notice: t(".approved", parent: claim.user.name, child: claim.child.fullname)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_child_claims_path, status: :see_other, alert: e.record.errors.full_messages.to_sentence
    end

    def reject
      claim = ChildClaim.pending.find(params.expect(:id))
      claim.reject!(current_user)
      redirect_to admin_child_claims_path, status: :see_other,
                                           notice: t(".rejected", email: claim.user.email, child: claim.child.fullname)
    end
  end
end
