# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Everything a job changes is posted to the site activity room as one message
  around_perform { |_job, block| SiteActivity.collect(&block) }

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
