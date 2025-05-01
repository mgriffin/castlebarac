# frozen_string_literal: true

class ResultPolicy < ApplicationPolicy
  def view_person?
    user
  end
end
