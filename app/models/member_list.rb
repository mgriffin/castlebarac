# frozen_string_literal: true

# Reads the club's member list for a year, as exported from Athletics
# Ireland: a table with the columns Reg Life ID, First Name, Last Name, Date
# Of Birth and M/F. Other columns, like Age, are ignored. The table can be
# in a text document or spreadsheet (.odt or .ods), or a .csv file.
class MemberList
  class Error < StandardError; end

  # A member as the list has them. problem says why the row can't be used.
  Row = Data.define(:aai_number, :firstname, :surname, :year, :gender, :problem) do
    def fullname = "#{firstname} #{surname}"
  end

  # Each column's heading, lowercased with only letters and digits left
  COLUMNS = {
    aai_number: %w[reglifeid aainumber],
    firstname: %w[firstname],
    surname: %w[lastname surname],
    date_of_birth: %w[dateofbirth dob],
    gender: %w[mf gender sex]
  }.freeze

  GENDERS = { "m" => "male", "f" => "female" }.freeze

  # Only content.xml is read, and a member list's is well under this
  MAX_CONTENT_SIZE = 20.megabytes

  OPEN_DOCUMENT_TABLE = "urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  OPEN_DOCUMENT_TEXT = "urn:oasis:names:tc:opendocument:xmlns:text:1.0"

  # file: an upload, or anything with #read and #original_filename
  def self.read(file)
    table = case File.extname(file.original_filename.to_s).downcase
            when ".csv" then CSV.parse(file.read.force_encoding(Encoding::UTF_8).delete_prefix("﻿"))
            when ".odt", ".ods" then open_document_table(file.read)
            else raise Error, "Upload the member list as a .odt, .ods or .csv file"
            end
    new(table).rows
  rescue CSV::MalformedCSVError, Zip::Error, Nokogiri::XML::SyntaxError
    raise Error, "That file couldn't be read. Check it's the member list."
  end

  # The cells of every table row in an OpenDocument file
  def self.open_document_table(data)
    entry = Zip::File.open_buffer(StringIO.new(data)).find_entry("content.xml")
    raise Error, "That file couldn't be read. Check it's the member list." if entry.nil?
    raise Error, "That file is too big to be a member list" if entry.size > MAX_CONTENT_SIZE

    xml = entry.get_input_stream.read

    Nokogiri::XML(xml).xpath("//table:table-row", "table" => OPEN_DOCUMENT_TABLE).map do |row|
      open_document_cells(row)
    end
  end

  def self.open_document_cells(row)
    row.xpath("table:table-cell | table:covered-table-cell", "table" => OPEN_DOCUMENT_TABLE).flat_map do |cell|
      text = cell.xpath(".//text:p", "text" => OPEN_DOCUMENT_TEXT).map(&:text).join(" ")
      # Spreadsheets repeat empty cells to the end of the row thousands of times
      repeat = cell.attribute_with_ns("number-columns-repeated", OPEN_DOCUMENT_TABLE)&.value.to_i
      [text] * repeat.clamp(1, 50)
    end
  end

  def initialize(table)
    @table = table.map { |cells| cells.map { it.to_s.squish } }
  end

  def rows
    header_index = @table.index { header?(it) }
    raise Error, missing_columns_message if header_index.nil?

    columns = column_positions(@table[header_index])
    @table.drop(header_index + 1)
          .reject { |cells| cells.all?(&:blank?) || header?(cells) }
          .map { |cells| row(columns.transform_values { cells[it].to_s }) }
  end

  private

  def heading(text) = text.downcase.gsub(/[^a-z0-9]/, "")

  def header?(cells)
    headings = cells.map { heading(it) }
    COLUMNS.values.all? { headings.intersect?(it) }
  end

  def column_positions(cells)
    headings = cells.map { heading(it) }
    COLUMNS.transform_values { |names| headings.index { names.include?(it) } }
  end

  def missing_columns_message
    "The member list needs a table with the columns Reg Life ID, First Name, Last Name, Date Of Birth and M/F"
  end

  def row(values)
    year = values[:date_of_birth][/\b(?:19|20)\d\d\b/]&.to_i
    gender = GENDERS[values[:gender].downcase.first]

    Row.new(aai_number: values[:aai_number], firstname: values[:firstname], surname: values[:surname],
            year:, gender:, problem: problem(values, year, gender))
  end

  def problem(values, year, gender)
    if values[:aai_number].blank? then "There's no Reg Life ID"
    elsif values[:firstname].blank? || values[:surname].blank? then "The name isn't filled in"
    elsif year.nil? then "The date of birth #{values[:date_of_birth].inspect} doesn't have a year"
    elsif gender.nil? then "The gender should be M or F"
    end
  end
end
