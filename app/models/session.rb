# frozen_string_literal: true

class Session < ApplicationRecord
  has_secure_token

  belongs_to :user

  def self.start!(user_agent:, ip_address:)
    create! user_agent: user_agent, ip_address: ip_address
  end
end
