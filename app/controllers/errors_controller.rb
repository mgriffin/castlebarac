# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    message = "#{request.method} #{request.original_url} wasn't found"
    PostToZulipJob.perform_later(message:, stream: "castlebarac", topic: "Page not found")

    render "errors/not_found", status: :not_found
  end

  def internal_error
    message = "#{request.method} #{request.original_url} caused an error"
    PostToZulipJob.perform_later(message:, stream: "castlebarac", topic: "Internal error")

    render "errors/internal_error", status: :internal_server_error
  end
end
