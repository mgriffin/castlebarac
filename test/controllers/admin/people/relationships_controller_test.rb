# frozen_string_literal: true

require "test_helper"

module Admin
  module People
    class RelationshipsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      def link(parent, child)
        post admin_person_relationships_url(parent), params: { person_relationship: { child_id: child&.id } }
      end

      test "anonymous visitors can't link people" do
        link(people(:bugsbunny), people(:snori))

        assert_response :not_found
        assert_empty people(:bugsbunny).children
      end

      test "users who aren't staff can't link people" do
        sign_in users(:bugs)

        link(people(:bugsbunny), people(:snori))

        assert_response :not_found
        assert_empty people(:bugsbunny).children
      end

      test "admins can link a parent to their child" do
        sign_in users(:admin)

        link(people(:bugsbunny), people(:snori))

        assert_redirected_to edit_admin_person_url(people(:bugsbunny))
        assert_equal "Linked Bugs Bunny as the parent of Snörí Snöríssøň", flash[:notice]
        assert_includes people(:bugsbunny).children, people(:snori)
      end

      test "linking people again doesn't link them twice" do
        PersonRelationship.create!(parent: people(:bugsbunny), child: people(:snori))
        sign_in users(:admin)

        assert_no_difference -> { PersonRelationship.count } do
          link(people(:bugsbunny), people(:snori))
        end

        assert_equal "Bugs Bunny is already linked as the parent of Snörí Snöríssøň", flash[:notice]
      end

      test "a child has to be chosen" do
        sign_in users(:admin)

        assert_no_difference -> { PersonRelationship.count } do
          link(people(:bugsbunny), nil)
        end

        assert_redirected_to edit_admin_person_url(people(:bugsbunny))
        assert_match "Child must exist", flash[:alert]
      end

      test "unknown people are not found" do
        sign_in users(:admin)

        post admin_person_relationships_url("no-such-person"),
             params: { person_relationship: { child_id: people(:snori).id } }

        assert_response :not_found
      end

      test "the edit page has a form for linking a child" do
        sign_in users(:admin)

        get edit_admin_person_url(people(:bugsbunny))

        assert_select "form[action='#{admin_person_relationships_path(people(:bugsbunny))}'] " \
                      "input[name='person_relationship[child_id]']"
        assert_select "input[name='person_relationship[parent_id]']", count: 0
      end
    end
  end
end
