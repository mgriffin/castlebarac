# frozen_string_literal: true

# The admin area as a whole, for pages that aren't about one record
class AdminPolicy < ApplicationPolicy
  def access?
    admin?
  end
end
