require "test_helper"

class MailingListsControllerTest < ActionDispatch::IntegrationTest
  test "can save an email address" do
    assert_difference("MailingList.count") do
      post mailing_lists_url, params: { mailing_list: { address: "bugs@acme.fake" } }
    end
  end
end
