# frozen_string_literal: true

class TtTime < ApplicationRecord
  belongs_to :time_trial
  belongs_to :person
end
