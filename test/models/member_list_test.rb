# frozen_string_literal: true

require "test_helper"

class MemberListTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  def read(name)
    MemberList.read(fixture_file_upload("member_lists/#{name}"))
  end

  def read_csv(text, name: "members.csv")
    MemberList.read(Rack::Test::UploadedFile.new(StringIO.new(text), "text/csv", original_filename: name))
  end

  test "reads a member list in a text document" do
    rows = read("members.odt")

    assert_equal %w[400001 400002 400003], rows.map(&:aai_number)
    assert_equal ["Ciara Walsh", "Niamh Ó Súilleabháin", "Tadhg Burke"], rows.map(&:fullname)
    assert_equal [2015, 2016, 2012], rows.map(&:year)
    assert_equal %w[female female male], rows.map(&:gender)
    assert_nil rows.first.problem
  end

  test "reads a member list in a CSV file" do
    rows = read("members.csv")

    assert_equal ["Ciara Walsh", "Liam Walsh"], rows.map(&:fullname)
    assert_equal [2015, 2015], rows.map(&:year)
    assert_equal %w[female male], rows.map(&:gender)
  end

  test "finds the columns whatever their order, and skips blank rows and repeated headings" do
    rows = read_csv("﻿CAC members 2026\n\nGender,Surname,First name,DOB,AAI Number\n\n" \
                    "Male,Burke,Tadhg,1/1/2012,400003\nGender,Surname,First name,DOB,AAI Number\n")

    assert_equal 1, rows.size
    assert_equal ["400003", "Tadhg", "Burke", 2012, "male"],
                 rows.first.to_h.values_at(:aai_number, :firstname, :surname, :year, :gender)
  end

  test "says what's wrong with rows it can't use" do
    rows = read_csv("Reg Life ID,First Name,Last Name,Date Of Birth,M/F\n" \
                    ",Ciara,Walsh,03/04/2015,F\n400002,,Walsh,03/04/2015,F\n" \
                    "400003,Tadhg,Burke,unknown,M\n400004,Liam,Walsh,03/04/2015,X\n")

    assert_equal ["There's no Reg Life ID", "The name isn't filled in",
                  "The date of birth \"unknown\" doesn't have a year", "The gender should be M or F"],
                 rows.map(&:problem)
  end

  test "needs the right columns" do
    error = assert_raises(MemberList::Error) { read_csv("Name,Born\nCiara Walsh,2015\n") }

    assert_match(/needs a table with the columns Reg Life ID/, error.message)
  end

  test "only reads documents, spreadsheets and CSV files" do
    error = assert_raises(MemberList::Error) { read_csv("whatever", name: "members.pdf") }

    assert_match(/\.odt, \.ods or \.csv/, error.message)
  end

  test "says when a file isn't really a document" do
    error = assert_raises(MemberList::Error) { read_csv("not a zip file", name: "members.odt") }

    assert_match(/couldn't be read/, error.message)
  end
end
