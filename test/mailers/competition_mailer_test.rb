# frozen_string_literal: true

require "test_helper"

class CompetitionMailerTest < ActionMailer::TestCase
  setup do
    @entry = Entry.create!(competition: competitions(:connacht), user: users(:bugs))
    @entry.entry_lines.create!(person: people(:ciara), competition_event: competition_events(:u12_girls_600m),
                               paid_at: Time.current)
    @entry.entry_lines.create!(person: people(:liam), competition_event: competition_events(:u12_boys_600m))
  end

  test "confirmation" do
    payment = @entry.payments.create!(amount_cents: 500, status: :paid)
    email = CompetitionMailer.with(payment:).confirmation

    assert_equal ["bugs@acme.fake"], email.to
    assert_equal "Your entry for Connacht Juvenile Championships", email.subject
    assert_match "We've received your payment of €5.00", email.text_part.body.to_s
    assert_match "Ciara Walsh\n  - U12 Girls 600m", email.text_part.body.to_s
    assert_no_match "Liam", email.text_part.body.to_s
    assert_match "<li>U12 Girls 600m</li>", email.html_part.body.to_s
  end
end
