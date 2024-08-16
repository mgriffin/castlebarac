# frozen_string_literal: true

class Session < ApplicationRecord
  has_secure_token

  belongs_to :user

  before_create { self.last_active_at ||= Time.now.utc }

  def self.start!(user_agent:, ip_address:)
    create! user_agent:, ip_address:
  end

  def resume(user_agent:, ip_address:)
    return unless last_active_at.before?(1.hour.ago)

    update! user_agent:, ip_address:, last_active_at: Time.now.utc
  end
end
