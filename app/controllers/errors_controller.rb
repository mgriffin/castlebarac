# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    render "errors/not_found", status: :not_found
  end

  def internal_error
    exception = ActionDispatch::ExceptionWrapper.new(
      Rails.backtrace_cleaner,
      request.env["action_dispatch.exception"]
    )

    render "errors/internal_error", status: :internal_server_error, locals: { exception: }
  end
end
