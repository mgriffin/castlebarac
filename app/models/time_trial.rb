# frozen_string_literal: true

class TimeTrial < ApplicationRecord
  has_many :tt_times, inverse_of: :time_trial, dependent: :destroy
  accepts_nested_attributes_for :tt_times
end
