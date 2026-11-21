# frozen_string_literal: true

# Posts what's happening on the site into a chat room on the club's Prosody
# server, so staff can watch sign-ups, logins and changes as they happen.
#
# Everything noted while handling one request or running one job is posted
# as one message, so a big upload doesn't flood the room. Outside of that,
# e.g. in the console, each note is posted straight away.
#
# The room's webhook URL (from Prosody's mod_slack_webhooks) is a secret, as
# anyone with it can post. Production reads it from the prosody.webhook_url
# credential, and PROSODY_WEBHOOK_URL sets it anywhere. Without it nothing is
# posted.
class SiteActivity
  # Up to this many changes are listed one by one; any more are counted
  LIST_LIMIT = 5

  # Readable names for fields that aren't readable themselves
  FIELD_NAMES = { "encrypted_password" => "password" }.freeze

  VERBS = { create: "added", update: "edited", destroy: "removed" }.freeze
  ICONS = { create: "➕", update: "✏️", destroy: "🗑️" }.freeze

  class << self
    def webhook_url
      ENV.fetch("PROSODY_WEBHOOK_URL") { Rails.configuration.x.prosody_webhook_url.presence }
    end

    def enabled? = webhook_url.present?

    # Gathers up everything noted inside the block and posts it as one
    # message. The actor says who's doing it, and is called when posting.
    def collect(actor: -> {}, ip: nil)
      return yield if Current.site_activity || !enabled?

      activity = Current.site_activity = new(actor:, ip:)
      begin
        yield
      ensure
        Current.site_activity = nil
        activity.post
      end
    end

    # A line of its own, e.g. a login
    def note(line)
      with_activity { it.note(line) }
    end

    # A record that was added, edited or removed
    def record(record, action)
      with_activity { it.record(record, action) }
    end

    private

    # Reporting activity must never get in the way of what's being reported
    def with_activity
      return unless enabled?

      collect { yield Current.site_activity }
    rescue StandardError => e
      Rails.logger.error("Couldn't note site activity: #{e.class}: #{e.message}")
    end
  end

  def initialize(actor: -> {}, ip: nil)
    @actor = actor
    @ip = ip
    @lines = []
    # Only the first few changes are described; the rest are only counted
    @listed = []
    @counts = Hash.new(0)
  end

  def note(line)
    @lines << line
  end

  def record(record, action)
    # New accounts get a line of their own, as they're not anyone's change
    return note(new_account(record)) if action == :create && record.is_a?(User)

    fields = action == :update ? changed_fields(record) : []
    return if action == :update && fields.empty?

    @counts[[action, record.class]] += 1
    @listed << [action, describe(record, fields)] if @listed.size < LIST_LIMIT
  end

  def post
    text = to_s
    SiteActivityJob.perform_later(text) if text.present?
  end

  def to_s
    [*change_lines, *@lines].join("\n")
  end

  private

  def new_account(user)
    "🆕 New account: #{user.username} (#{user.email}) from #{@ip || 'an unknown address'}"
  end

  def changed_fields(record)
    (record.saved_changes.keys - record.site_activity_ignored_fields)
      .map { FIELD_NAMES.fetch(it) { it.humanize(capitalize: false) } }
  end

  # e.g. "edited event “Mayo Championships” (title and start time)"
  def describe(record, fields)
    type = record.model_name.human.downcase
    name = record.try(:site_activity_name) ||
           %i[fullname title name username].lazy.filter_map { record.try(it).presence }.first
    label = name ? "#{type} “#{name}”" : "#{type} ##{record.id}"
    fields.any? ? "#{label} (#{fields.to_sentence})" : label
  end

  def change_lines
    total = @counts.values.sum
    return [] if total.zero?

    actor = @actor.call || "The site"
    return ["📋 #{actor} made #{total} changes: #{counts}"] if total > LIST_LIMIT

    @listed.map { |action, description| "#{ICONS[action]} #{actor} #{VERBS[action]} #{description}" }
  end

  # e.g. "added 186 people, edited 21 people and removed 3 club memberships"
  def counts
    @counts.map do |(action, model), count|
      "#{VERBS[action]} #{count} #{model.model_name.human.downcase.pluralize(count)}"
    end.to_sentence
  end
end
