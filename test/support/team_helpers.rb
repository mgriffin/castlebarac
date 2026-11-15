# frozen_string_literal: true

# Setting up team memberships that the fixtures don't have
module TeamHelpers
  def make_committee_member(user)
    Team.find_or_create_by!(name: "Committee").people << user.person
  end
end

ActiveSupport.on_load(:active_support_test_case) { include TeamHelpers }
