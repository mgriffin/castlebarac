# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.12"

gem "nokogiri", "1.19.4"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.6"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

### For authentication
gem "devise"
gem "pretender"
gem "typhoeus"
### Need to include this now
gem "csv"
### Reads member lists saved as OpenDocument files, which are zip files
gem "rubyzip", "~> 3.7", require: "zip"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem "rubocop"
  gem "rubocop-capybara"
  gem "rubocop-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]

  gem "faker"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "mocha"
  gem "webmock"
end

gem "flipper-active_record", "~> 1.3"
gem "flipper-ui"

gem "inline_svg"
gem "lograge"
gem "view_component"

gem "pundit", "~> 2.5"

gem "friendly_id", "~> 5.7.0"

gem "solid_queue", "~> 1.7"

gem "stripe", "~> 21.0"
