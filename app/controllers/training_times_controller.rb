# frozen_string_literal: true

class TrainingTimesController < ApplicationController
  # Public pages
  skip_after_action :verify_authorized

  def index; end
end
