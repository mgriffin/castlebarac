# frozen_string_literal: true

module Admin
  # Updates a year's member list from the club's member list in three steps:
  # upload the file (new), check what will change and choose who's who where
  # it isn't clear (preview), then make the changes (create).
  #
  # Not Admin::BaseController, which only lets admins in: committee members
  # keep the member list too.
  class MemberListsController < ApplicationController
    before_action { authorize [:admin, ClubMembership], :create? }

    rescue_from MemberList::Error do |error|
      redirect_to new_admin_member_list_path(year: params[:year]), alert: error.message
    end

    # GET /admin/member_lists/new
    def new
      @year = year
    end

    # POST /admin/member_lists/preview
    def preview
      file = params.fetch(:file, nil)
      raise MemberList::Error, "Choose the member list to upload" unless file.respond_to?(:read)

      rows = MemberList.read(file)
      raise MemberList::Error, "There's nobody on that member list" if rows.empty?

      @import = MemberListImport.new(rows:, year:)
      @upload = self.class.verifier.generate({ "year" => year, "rows" => rows.map(&:to_h) }, expires_in: 1.hour)
    end

    # POST /admin/member_lists
    def create
      upload = self.class.verifier.verified(params[:upload].to_s)
      raise MemberList::Error, "That upload has expired. Upload the member list again." if upload.nil?

      rows = upload["rows"].map { MemberList::Row.new(**it.symbolize_keys) }
      import = MemberListImport.new(rows:, year: upload["year"], choices: params.permit(choices: {})[:choices])
      counts = import.apply!
      linked = ResultLinker.new.link_matches.size

      redirect_to admin_members_path(year: import.year), notice: notice(import.year, counts, linked)
    end

    # The parsed list is kept in the preview page between steps, signed so
    # it can't be changed
    def self.verifier
      Rails.application.message_verifier("member_list")
    end

    private

    # Membership years run from January to December
    def year
      params[:year].to_i.nonzero? || Date.current.year
    end

    def notice(year, counts, linked)
      parts = ["#{counts[:added]} added", "#{counts[:updated]} updated", "#{counts[:removed]} taken off the list"]
      parts << "#{linked} #{'result'.pluralize(linked)} linked to their people" if linked.positive?
      "Updated the #{year} member list: #{parts.to_sentence}"
    end
  end
end
