# frozen_string_literal: true

class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :results, dependent: :nullify
  has_many :tt_times, dependent: :nullify, inverse_of: :person
  has_many :person_claims, dependent: :destroy
  has_many :child_claims, foreign_key: :child_id, inverse_of: :child, dependent: :destroy
  has_many :parent_child_relationships,
           class_name: "PersonRelationship",
           foreign_key: :child_id,
           inverse_of: :child,
           dependent: :destroy
  has_many :parents,
           through: :parent_child_relationships,
           source: :parent

  has_many :child_parent_relationships,
           class_name: "PersonRelationship",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :destroy
  has_many :children,
           through: :child_parent_relationships,
           source: :child

  include Competitor
  include ClubMember

  validates :user_id, uniqueness: true, allow_nil: true

  before_validation :create_slug, if: -> { slug.blank? || firstname_changed? || surname_changed? }

  # People whose first name or surname starts with the name, ignoring case
  # (SQLite's LIKE does). % and _ in the name are matched literally.
  scope :search, lambda { |name|
    where("firstname LIKE :name ESCAPE '\\' OR surname LIKE :name ESCAPE '\\'",
          name: "#{sanitize_sql_like(name.to_s)}%")
  }

  # e.g. "john-smith", or "john-smith-2" if there's already a John Smith
  def create_slug
    base = slugify("#{firstname} #{surname}")
    self.slug = base
    count = 1
    self.slug = "#{base}-#{count += 1}" while Person.where.not(id:).exists?(slug:)
  end

  def slugify(name)
    I18n.transliterate(name)
        .gsub(/\s+/, "-")    # replace spaces with -
        .gsub(/[^\w]+/, "-") # replace all non-word chars with -
        .gsub(/--+/, "-")    # replace multiple - with single -
        .gsub(/^-/, "")      # remove leading -
        .gsub(/-$/, "")      # remove trailing -
        .downcase
  end

  # { distance => [results] }, shortest distance first with races that have
  # no distance last, and the most recent results first in each group
  def results_by_distance
    results
      .includes(race: :event)
      .order(Result.arel_table[:distance].asc.nulls_last, Event.arel_table[:start_time].desc)
      .references(:events)
      .group_by(&:distance)
  end

  def to_param
    slug
  end

  # Nothing hangs off this person: no results, time trial times, teams,
  # club memberships, parents or children
  def unused?
    [results, tt_times, memberships, club_memberships, parents, children].none?(&:exists?)
  end

  def fullname
    [firstname, surname].join(" ")
  end

  # Words that are part of the surname that follows them, e.g. "O Brien"
  SURNAME_PREFIXES = %w[o ó mac mc nic ní ni ui uí de di da van von le la].freeze

  # Guesses the first name and surname from a name in a results list, e.g.
  # "Juliette NIC SUIBHNE", "Lucy O'Keeffe" or "O'Keeffe, Lucy"
  def self.split_name(name)
    surname, firstname = name.split(",", 2).map(&:squish) if name.include?(",")
    firstname, surname = split_words(name.squish.split) if firstname.nil?

    { firstname: tidy_name(firstname), surname: tidy_name(surname) }
  end

  def self.split_words(words)
    return [words.join(" "), ""] if words.size < 2

    # A surname in capitals, or else the last word and any prefixes before it
    count = words.reverse.take_while { |word| shouting?(word) }.size
    count = 1 unless count.between?(1, words.size - 1)
    count += 1 while count < words.size - 1 && SURNAME_PREFIXES.include?(words[-count - 1].downcase)

    [words[...-count].join(" "), words[-count..].join(" ")]
  end

  def self.tidy_name(name)
    name.to_s.split.map { |word| tidy_case(word) }.join(" ")
  end

  # Results lists often write surnames in capitals
  def self.shouting?(word)
    word.length > 1 && word == word.upcase && word != word.downcase
  end

  def self.tidy_case(word)
    return word unless shouting?(word)

    word.downcase.capitalize.gsub(/(['’-])(\p{L})/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).upcase}" }
  end

  # Everyone with this name, e.g. "Lucy O'Keeffe" or "O'KEEFFE, Lucy". There
  # can be more than one, with slugs like lucy-o-keeffe-2.
  def self.named(name)
    name = name.split(",").map(&:chomp).reverse.join(" ") if name.include?(", ")
    slug = new.slugify(name)

    candidates = where(slug:).or(where("slug LIKE ? ESCAPE '\\'", "#{sanitize_sql_like(slug)}-%"))
    candidates.select { it.slugify(it.fullname) == slug }
  end

  # The person with this name, or nil if there's no one or more than one
  def self.match(name)
    people = named(name)
    people.first if people.one?
  end
end
