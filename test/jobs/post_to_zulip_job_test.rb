# frozen_string_literal: true

require "test_helper"

class PostToZulipJobTest < ActiveJob::TestCase
  test "sends a message to the right channel" do
    Zulip.any_instance.expects(:post).with(
      message: "Test message",
      stream: "general",
      topic: "This is from a test"
    )

    perform_enqueued_jobs do
      PostToZulipJob.perform_later(
        message: "Test message",
        stream: "general",
        topic: "This is from a test"
      )
    end
  end
end
