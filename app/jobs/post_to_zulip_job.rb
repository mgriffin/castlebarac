# frozen_string_literal: true

class PostToZulipJob < ApplicationJob
  queue_as :default

  def perform(message:, stream:, topic:)
    Zulip.new.post(message:, stream:, topic:)
  end
end
