# frozen_string_literal: true

# Logins and failed logins are posted to the site activity room (see
# SiteActivity). Coming back with a remembered login isn't counted, or every
# visit would be posted. Being logged in straight after signing up isn't
# either, as the new account is posted.
Warden::Manager.after_authentication do |user, auth, _options|
  next if auth.winning_strategy.is_a?(Devise::Strategies::Rememberable)

  ip = ActionDispatch::Request.new(auth.env).remote_ip
  SiteActivity.note("🔑 #{user.username} logged in from #{ip}")
end

# Only the first failure from an address in a while is posted, so someone
# guessing passwords doesn't flood the room. Logging in is the only failure
# that recalls a page; others are e.g. visiting a page that needs a login.
Warden::Manager.before_failure do |env, options|
  next unless options[:recall]

  request = ActionDispatch::Request.new(env)
  next unless Rails.cache.write("site_activity/failed_login/#{request.remote_ip}", true,
                                unless_exist: true, expires_in: 10.minutes)

  email = request.request_parameters.dig("user", "email").presence || "no email"
  SiteActivity.note("⚠️ Failed login for #{email} from #{request.remote_ip} " \
                    "(more from there in the next 10 minutes won't be posted)")
end
