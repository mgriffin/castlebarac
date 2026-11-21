# frozen_string_literal: true

# Per-request state, reset by Rails after each request and job
class Current < ActiveSupport::CurrentAttributes
  attribute :site_activity
end
