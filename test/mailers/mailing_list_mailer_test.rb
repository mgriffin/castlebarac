# frozen_string_literal: true

require "test_helper"

class MailingListMailerTest < ActionMailer::TestCase
  test "welcome" do
    email = MailingListMailer.with(email: "bugs@acme.fake").welcome

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["info@castlebarac.ie"], email.from
    assert_equal ["bugs@acme.fake"], email.to
    assert_equal "Thanks for signing up to the mailing list", email.subject
    assert_equal read_fixture("welcome_text").join, email.text_part.body.to_s
    assert_equal read_fixture("welcome_html").join, email.html_part.body.to_s
  end
end
