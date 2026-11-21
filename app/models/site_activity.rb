# frozen_string_literal: true

# Posts what's happening on the site into a chat room on the club's Prosody
# server, so staff can watch sign-ups, logins and changes as they happen.
#
# Everything noted while handling one request or running one job is posted
# as one message, so a big upload doesn't flood the room. Outside of that,
# e.g. in the console, each note is posted straight away.
#
# The room's webhook URL (from Prosody's mod_slack_webhooks) is a secret, as
# anyone with it can post: it goes in the prosody.webhook_url credential,
# which is only used in production, or PROSODY_WEBHOOK_URL. Without it
# nothing is posted.
class SiteActivity
  # Up to this many changes are listed one by one; any more are counted
  LIST_LIMIT = 5

  # Changes to these aren't worth a message on their own. URLs are made
  # from titles.
  IGNORED_FIELDS = %w[
    created_at updated_at
    sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip
    remember_created_at reset_password_token reset_password_sent_at
    reminder_sent_at url
  ].freeze

  # Readable names for fields that aren't readable themselves
  FIELD_NAMES = { "encrypted_password" => "password" }.freeze

  VERBS = { create: "added", update: "edited", destroy: "removed" }.freeze
  ICONS = { create: "➕", update: "✏️", destroy: "🗑️" }.freeze

  Change = Data.define(:action, :record, :fields)

  class << self
    # The credentials are shared with development, which shouldn't post to
    # the room, so they're only used in production
    def webhook_url
      ENV.fetch("PROSODY_WEBHOOK_URL") do
        Rails.application.credentials.dig(:prosody, :webhook_url) if Rails.env.production?
      end
    end

    def enabled? = webhook_url.present?

    # Gathers up everything noted inside the block and posts it as one
    # message. The actor is who's doing it, worked out when posting.
    def collect(actor: nil, ip: nil)
      return yield if Current.site_activity

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
      with_activity { it.lines << line }
    end

    # A record that was added, edited or removed
    def record(record, action)
      fields = action == :update ? changed_fields(record) : []
      return if action == :update && fields.empty?

      with_activity { it.changes << Change.new(action:, record:, fields:) }
    end

    private

    # Reporting activity must never get in the way of what's being reported
    def with_activity
      return unless enabled?

      activity = Current.site_activity || new
      yield activity
      activity.post unless Current.site_activity
    rescue StandardError => e
      Rails.logger.error("Couldn't note site activity: #{e.class}: #{e.message}")
    end

    def changed_fields(record)
      (record.saved_changes.keys - IGNORED_FIELDS).map { FIELD_NAMES.fetch(it) { it.humanize(capitalize: false) } }
    end
  end

  attr_reader :lines, :changes

  def initialize(actor: nil, ip: nil)
    @actor = actor
    @ip = ip
    @lines = []
    @changes = []
  end

  def post
    text = to_s
    SiteActivityJob.perform_later(text) if text.present?
  end

  def to_s
    [*account_lines, *change_lines, *lines].join("\n")
  end

  private

  # New accounts get a line of their own, as they're not anyone's change
  def account_lines
    changes.filter_map do |change|
      next unless change.action == :create && change.record.is_a?(User)

      "🆕 New account: #{change.record.username} (#{change.record.email}) from #{@ip || 'an unknown address'}"
    end
  end

  def change_lines
    listed = changes.reject { it.action == :create && it.record.is_a?(User) }
    return [] if listed.empty?
    return ["📋 #{actor} made #{listed.size} changes: #{counts(listed)}"] if listed.size > LIST_LIMIT

    listed.map do |change|
      fields = " (#{change.fields.to_sentence})" if change.fields.any?
      "#{ICONS[change.action]} #{actor} #{VERBS[change.action]} #{label(change.record)}#{fields}"
    end
  end

  # e.g. "added 186 people, edited 21 people and removed 3 club memberships"
  def counts(changes)
    changes.group_by { [it.action, it.record.class] }.map do |(action, model), group|
      "#{VERBS[action]} #{group.size} #{model.model_name.human.downcase.pluralize(group.size)}"
    end.to_sentence
  end

  def label(record)
    type = record.model_name.human.downcase
    name = record.try(:site_activity_name) ||
           %i[fullname title name username].lazy.filter_map { record.try(it).presence }.first
    name ? "#{type} “#{name}”" : "#{type} ##{record.id}"
  end

  def actor
    (@actor.respond_to?(:call) ? @actor.call : @actor) || "The site"
  end
end
