# frozen_string_literal: true

class ResultsTableComponent < ViewComponent::Base
  renders_many :results, ResultComponent

  def initialize(first_result:)
    @first_result = first_result
  end

  def headers
    class_names({
                  "position" => true,
                  "bib" => @first_result&.bib.present?,
                  "name" => true,
                  "club" => true,
                  "county" => @first_result&.county.present?,
                  "time" => @first_result&.seconds.present?
                }).split
  end

  # "Position" is too wide for its column
  def label(header)
    return tag.abbr("Pos", title: "Position") if header == "position"

    header.humanize
  end
end
