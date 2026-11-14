# frozen_string_literal: true

require "test_helper"

module Admin
  module People
    class AccountsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      def link(person, email)
        post admin_person_account_url(person), params: { email: }
      end

      test "only admins can link and unlink accounts" do
        link(people(:snori), "gabbygabby@acme.fake")
        assert_response :not_found

        sign_in users(:coach)
        link(people(:snori), "gabbygabby@acme.fake")
        assert_response :not_found
        delete admin_person_account_url(people(:bugsbunny))
        assert_response :not_found

        assert_nil users(:gabby).reload.person
        assert_equal users(:bugs), people(:bugsbunny).reload.user
      end

      test "admins can link a person to an account by email address" do
        sign_in users(:admin)

        link(people(:snori), " GabbyGabby@acme.fake ")

        assert_redirected_to edit_admin_person_url(people(:snori))
        assert_equal "Linked gabbygabby@acme.fake to Snörí Snöríssøň", flash[:notice]
        assert_equal people(:snori), users(:gabby).reload.person
      end

      test "says when there's no account with the email address" do
        sign_in users(:admin)

        link(people(:snori), "nobody@acme.fake")

        assert_redirected_to edit_admin_person_url(people(:snori))
        assert_equal "There's no account with that email address", flash[:alert]
        assert_nil people(:snori).reload.user
      end

      test "says why a person can't be linked" do
        sign_in users(:admin)

        link(people(:bugsbunny), "gabbygabby@acme.fake")

        assert_equal "Bugs Bunny is already linked to another account", flash[:alert]
        assert_equal users(:bugs), people(:bugsbunny).reload.user
      end

      test "admins can unlink an account" do
        sign_in users(:admin)

        delete admin_person_account_url(people(:bugsbunny))

        assert_redirected_to edit_admin_person_url(people(:bugsbunny))
        assert_equal "Unlinked bugs@acme.fake from Bugs Bunny", flash[:notice]
        assert_nil people(:bugsbunny).reload.user
      end

      test "the person's edit page shows their account, or a form to link one" do
        sign_in users(:admin)

        get edit_admin_person_url(people(:bugsbunny))
        assert_select "a[href=?]", admin_user_path(users(:bugs)), text: "bugs@acme.fake"
        assert_select "form[action=?] button", admin_person_account_path(people(:bugsbunny)), text: "Unlink account"

        get edit_admin_person_url(people(:snori))
        assert_select "form[action=?] input[type=email][name=email]", admin_person_account_path(people(:snori))
      end
    end
  end
end
