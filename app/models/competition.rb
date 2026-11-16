# frozen_string_literal: true

class Competition < ApplicationRecord
  extend FriendlyId

  friendly_id :date_and_name, use: :slugged

  LEVELS = %w[regional provincial national].freeze

  enum :level, LEVELS.index_by(&:itself), validate: true
  enum :status, { draft: "draft", open: "open", closed: "closed" }, prefix: :entries, default: "draft"

  belongs_to :event, optional: true
  has_many :competition_events, -> { order(:position, :id) },
           dependent: :destroy,
           inverse_of: :competition
  has_many :entries, dependent: :restrict_with_error
  has_many :entry_lines, through: :entries

  has_rich_text :description

  accepts_nested_attributes_for :competition_events,
                                allow_destroy: true,
                                reject_if: ->(attributes) { attributes[:name].blank? }

  scope :upcoming, -> { where(date: Date.current..).order(:date) }
  scope :published, -> { where.not(status: :draft) }

  validates :name, :date, :entries_close_at, presence: true
  validates :max_events_per_athlete, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :fee_per_event_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :entries_close_before_competition

  def date_and_name
    "#{date&.strftime('%Y-%m-%d')} #{name}"
  end

  def should_generate_new_friendly_id?
    name_changed? || date_changed? || super
  end

  # Entries can only be made or changed while they're open and the closing
  # date hasn't passed
  def accepting_entries?(at = Time.current)
    entries_open? && at < entries_close_at
  end

  # Athletics Ireland age groups go by age on 31 December of the year of the
  # competition
  def age_reference_date
    Date.new(date.year, 12, 31)
  end

  def fee_per_event
    fee_per_event_cents / 100.0
  end

  def fee_per_event=(euros)
    self.fee_per_event_cents = (BigDecimal(euros.to_s.presence || "0") * 100).round
  rescue ArgumentError
    errors.add(:fee_per_event, :not_a_number)
  end

  def open_entries
    errors.add(:base, :no_events) if competition_events.none?
    errors.add(:base, :no_fee) unless fee_per_event_cents.positive?
    errors.add(:entries_close_at, :in_the_past) if entries_close_at.blank? || entries_close_at.past?
    return false if errors.any?

    entries_open!
  end

  def close_entries
    entries_closed!
  end

  private

  def entries_close_before_competition
    return if date.blank? || entries_close_at.blank?
    return if entries_close_at.to_date <= date

    errors.add(:entries_close_at, :after_competition)
  end
end
