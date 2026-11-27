# frozen_string_literal: true

require_relative "boot"

require "rails"
# The frameworks the site uses. Action Cable and Action Mailbox are left out.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_text/engine"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Castlebarac
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # config.action_mailer.delivery_method = :smtp

    ### For Pundit
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :not_found
  end

  def self.show_about?(user = nil)
    Flipper.enabled?(:about, user)
  end

  def self.truncate_post?(user = nil)
    Flipper.enabled?(:truncate_post, user)
  end

  # Competition entries and payments. Turn on for individual users in
  # Flipper to try them out before opening them to everyone.
  def self.competition_entries?(user = nil)
    Flipper.enabled?("comp-entries", user)
  end
end
