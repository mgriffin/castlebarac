# frozen_string_literal: true

require "test_helper"

Capybara.register_driver :my_playwright do |app|
  Capybara::Playwright::Driver.new(app,
                                   browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
                                   headless: (false unless ENV["CI"] || ENV["PLAYWRIGHT_HEADLESS"]))
end
Capybara.default_driver = :playwright
Capybara.default_max_wait_time = 15
WebMock.disable_net_connect!(allow_localhost: true)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Warden::Test::Helpers

  driven_by :my_playwright

  def ensure_turbo_frames_are_complete
    frames = page.all("turbo-frame")
    page.assert_selector("turbo-frame[complete]", minimum: frames.count)
  end
end
