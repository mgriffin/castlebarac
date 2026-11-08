# frozen_string_literal: true

# Stubs the results websites with the pages in test/fixtures/files/result_sources
module ResultSourceStubs
  POP_UP_RACES_URL = "https://www.popupraces.ie/race/mayo-primary-schools-xc-2026/"
  CONNAUGHT_XC_URL = "https://connaughtathletics.com/XC/mayo-xc-uneven-ages-2026"
  # Regional competitions also give each runner's county
  CONNAUGHT_XC_REGIONAL_URL = "https://connaughtathletics.com/XC/ryvg3rgkpg"

  def stub_result_sources
    stub_page(POP_UP_RACES_URL, "pop_up_races.html")
    stub_page(%r{\Ahttps://my\.raceresult\.com/424867/results/config}, "race_result_config.json")
    stub_page(%r{\Ahttps://my1\.raceresult\.com/424867/results/list}, "race_result_list.json")
    stub_page(CONNAUGHT_XC_URL, "connaught_xc.html")
    stub_page(%r{\A#{CONNAUGHT_XC_URL}/u9-(girls|boys)\z}, "connaught_xc_race.html")
    stub_page("#{CONNAUGHT_XC_REGIONAL_URL}/u9-boys", "connaught_xc_race_with_counties.html")
  end

  private

  def stub_page(url, file)
    stub_request(:get, url).to_return(body: file_fixture("result_sources/#{file}").read)
  end
end
