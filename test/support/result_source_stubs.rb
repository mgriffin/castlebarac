# frozen_string_literal: true

# Stubs the results websites with the pages in test/fixtures/files/result_sources
module ResultSourceStubs
  POP_UP_RACES_URL = "https://www.popupraces.ie/race/mayo-primary-schools-xc-2026/"
  CONNAUGHT_XC_URL = "https://connaughtathletics.com/XC/mayo-xc-uneven-ages-2026"
  # Regional competitions also give each runner's county
  CONNAUGHT_XC_REGIONAL_URL = "https://connaughtathletics.com/XC/ryvg3rgkpg"
  # Pop Up Races page that gives the date without the day of the week
  POP_UP_RACES_CASTLEGAR_URL = "https://www.popupraces.ie/race/castlegar-international-cross-country-2026/"
  CONNAUGHT_TRACK_URL = "https://connaughtathletics.com/2026/conninday3/competition.php"
  CONNAUGHT_LEGACY_XC_URL = "https://connaughtathletics.com/2025/connacht/XC/evens/"
  ATHLETICS_IRELAND_URL = "http://results.athleticsireland.ie/results_2026/06_27_out_juvenileday1+2/menu.html"

  def stub_result_sources
    stub_page(POP_UP_RACES_URL, "pop_up_races.html")
    stub_page(%r{\Ahttps://my\.raceresult\.com/424867/results/config}, "race_result_config.json")
    stub_page(%r{\Ahttps://my1\.raceresult\.com/424867/results/list}, "race_result_list.json")
    stub_page(CONNAUGHT_XC_URL, "connaught_xc.html")
    stub_page(%r{\A#{CONNAUGHT_XC_URL}/u9-(girls|boys)\z}, "connaught_xc_race.html")
    stub_page("#{CONNAUGHT_XC_REGIONAL_URL}/u9-boys", "connaught_xc_race_with_counties.html")
    stub_page(POP_UP_RACES_CASTLEGAR_URL, "pop_up_races_castlegar.html")
    stub_connaught_pages
    stub_athletics_ireland
  end

  def stub_connaught_pages
    base = "https://connaughtathletics.com/2026/conninday3/competition.php"
    stub_page(base, "connaught_track.html")
    { 777 => "60m", 779 => "long_jump", 790 => "relay" }.each do |id, file|
      stub_page("#{base}?id=#{id}", "connaught_track_#{file}.html")
    end
    stub_request(:get, "#{CONNAUGHT_LEGACY_XC_URL}competition.php").to_return(status: 404)
    stub_page(CONNAUGHT_LEGACY_XC_URL, "connaught_legacy_xc.html")
    stub_page(/\A#{CONNAUGHT_LEGACY_XC_URL}U10[GB]\.html\z/, "connaught_legacy_xc_race.html")
  end

  def stub_athletics_ireland
    base = "http://results.athleticsireland.ie/results_2026/06_27_out_juvenileday1+2/"
    stub_page("#{base}menu.xml", "athletics_ireland_menu.xml")
    { 3 => "400m", 14 => "discus", 73 => "relay" }.each do |id, file|
      stub_page("#{base}#{id}_list.xml", "athletics_ireland_#{file}.xml")
    end
  end

  private

  def stub_page(url, file)
    stub_request(:get, url).to_return(body: file_fixture("result_sources/#{file}").read)
  end
end
