# frozen_string_literal: true

class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :results, dependent: :nullify
  has_many :tt_times, dependent: :nullify, inverse_of: :person
  has_many :parent_child_relationships,
           class_name: "PersonRelationship",
           foreign_key: :child_id,
           inverse_of: :parent,
           dependent: :destroy
  has_many :parents,
           through: :parent_child_relationships,
           source: :parent

  has_many :child_parent_relationships,
           class_name: "PersonRelationship",
           foreign_key: :parent_id,
           inverse_of: :child,
           dependent: :destroy
  has_many :children,
           through: :child_parent_relationships,
           source: :child

  before_validation :create_slug

  scope :search, ->(name) { where("LOWER(firstname) LIKE :name OR LOWER(surname) LIKE :name", { name: "#{name}%" }) }

  def create_slug
    self.slug = slugify("#{firstname} #{surname}")
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

  def self.match(name)
    name = name.split(",").map(&:chomp).reverse.join(" ") if name.include?(", ")

    Person.find_by(slug: Person.new.slugify(name))
  end
end
