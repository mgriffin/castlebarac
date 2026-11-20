# frozen_string_literal: true

require "test_helper"

module Admin
  class MemberListsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      people(:ciara).update!(year: "2015")
      people(:liam).update!(year: "2015")
    end

    def upload(name = "members.odt", year: 2026)
      post preview_admin_member_lists_url, params: { file: fixture_file_upload("member_lists/#{name}"), year: }
    end

    def upload_csv(text, name: "members.csv", year: 2026)
      post preview_admin_member_lists_url,
           params: { year:, file: Rack::Test::UploadedFile.new(StringIO.new(text), "text/csv", original_filename: name) }
    end

    def signed_upload
      css_select("input[name=upload]").first["value"]
    end

    test "only admins and committee members can update the member list" do
      [nil, users(:bugs), users(:coach)].each do |user|
        sign_in user if user
        upload

        assert_response :not_found
      end

      sign_in users(:secretary)
      get new_admin_member_list_url

      assert_response :success
      assert_select "form[action='#{preview_admin_member_lists_path}'][data-turbo=false] input[type=file][name=file]"
    end

    test "shows what will change before changing anything" do
      ClubMembership.create!(person: people(:aoife), year: 2026)
      sign_in users(:admin)

      assert_no_difference %w[Person.count ClubMembership.count] do
        upload
      end

      assert_response :success
      assert_select "h1", "Check the 2026 member list"
      assert_select "p", /3 people on the list: 1 to update and 2 to add\./
      assert_select "p", /1 person will be taken off the 2026 list/
      assert_select "a[href='#{person_path(people(:ciara))}']", "Ciara Walsh"
      assert_select "td", /Add to the 2026 list/
      assert_select "td", "Niamh Ó Súilleabháin"
      assert_select "li a[href='#{person_path(people(:aoife))}']"
      assert_select "input[type=submit][value='Update the 2026 member list']"
    end

    test "asks who someone is when it isn't clear" do
      twin = Person.create!(firstname: "Ciara", surname: "Walsh")
      sign_in users(:admin)

      upload

      assert_select "select[name='choices[400001]']" do
        assert_select "option[selected]", "Leave out for now"
        assert_select "option[value='#{twin.id}']"
        assert_select "option[value='#{people(:ciara).id}']", "Ciara Walsh, born 2015 (##{people(:ciara).id})"
        assert_select "option[value=new]"
      end
    end

    test "updates the member list" do
      ClubMembership.create!(person: people(:aoife), year: 2026)
      twin = Person.create!(firstname: "Ciara", surname: "Walsh")
      sign_in users(:secretary)
      upload

      post admin_member_lists_url, params: { upload: signed_upload, choices: { "400001" => twin.id.to_s } }

      assert_redirected_to admin_members_path(year: 2026)
      assert_equal "Updated the 2026 member list: 2 added, 1 updated, and 1 taken off the list", flash[:notice]
      assert_equal "400001", twin.reload.aai_number
      assert_equal ["Ciara Walsh", "Niamh Ó Súilleabháin", "Tadhg Burke"],
                   Person.members_in(2026).order(:aai_number).map(&:fullname)
    end

    test "uploading the same list again changes nothing" do
      sign_in users(:admin)
      upload
      post admin_member_lists_url, params: { upload: signed_upload }

      upload

      assert_select "p", /3 people on the list: 3 already up to date\./
      assert_select ".alert-success", "The 2026 member list is already up to date."
      assert_select "input[type=submit]", 0
    end

    test "lists rows that can't be used" do
      sign_in users(:admin)

      upload_csv("Reg Life ID,First Name,Last Name,Date Of Birth,M/F\n400002,Tadhg,Burke,,M\n")

      assert_select "li", "Tadhg Burke: The date of birth \"\" doesn't have a year"
    end

    test "says when the file can't be read" do
      sign_in users(:admin)

      upload_csv("hello", name: "list.txt", year: 2025)

      assert_redirected_to new_admin_member_list_path(year: 2025)
      assert_match(/\.odt, \.ods or \.csv/, flash[:alert])
    end

    test "won't use an upload that's been changed or has expired" do
      sign_in users(:admin)
      upload
      signed = signed_upload

      assert_no_difference -> { ClubMembership.count } do
        post admin_member_lists_url, params: { upload: "#{signed}x" }
      end

      assert_redirected_to new_admin_member_list_path
      assert_match(/expired/, flash[:alert])

      travel 2.hours do
        post admin_member_lists_url, params: { upload: signed }
      end

      assert_match(/expired/, flash[:alert])
    end
  end
end
