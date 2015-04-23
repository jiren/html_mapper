require 'spec_helper'

describe HtmlMapper::ExportMapper do

  module ScraperTest
    class HasScraper
      include HtmlMapper

      collection :players, '.player' do
        field :name, '.name'
        field :photo, '.photo', attribute: 'src'
      end
    end

    class Scraper
      include HtmlMapper

      domains 'http://www.test.com'

      collection :events, '.commentary-event' do
        field :over, '.commentary-overs', as: Float
        field :text, '.commentary-text'
        has_many :players, 'ScraperTest::HasScraper'
      end
    end
  end

  let(:doc){ Nokogiri::HTML.parse(fixture_file('export.html'))}

  let(:scraper_hash) {
    {
     :domains=>["http://www.test.com"],
     :collections=>
      [{:name=> :events,
        :selector=>".commentary-event",
        :options=>{},
        :fields=>
         [{:name=> :over,
           :selector=>".commentary-overs",
           :options=>{:as=>"Float"}},
          {:name=> :text, :selector=>".commentary-text"}],
        :relations=>
         [{:name=> :players,
           :klass=>"ScraperTest::HasScraper",
           :options=>{:many=>true},
           :mapper=>
            {:domains=>nil,
             :collections=>
              [{:name=> :players,
                :selector=>".player",
                :options=>{},
                :fields=>
                 [{:name=> :name, :selector=>".name"},
                  {:name=> :photo,
                   :selector=>".photo",
                   :options=>{:attribute=>"src"}}],
                :relations=>[]}]}}]}]}
  }

  it 'export scraper' do
    mapper = ScraperTest::Scraper.export
    expect(mapper).to eq(scraper_hash)
  end

  it 'import scraper from  hash #to_mapper' do
    scraper = HtmlMapper.to_mapper(scraper_hash.to_json)

    result = JSON.parse(scraper.parse(doc).to_json)

    expected_result =
     {"events"=>
      [{"over"=>0.1,
        "text"=>
         "Steyn to RG Sharma, no run, swing straightaway, from middle to off from a fairly full length. Rohit defends solidly off the front foot",
        "players"=>
         {"players"=>
           [{"name"=>"Steyn", "photo"=>"http://test.com/Steyn.png"},
            {"name"=>"RG Sharma", "photo"=>"http://test.com/RGSharma.png"}]}},
       {"over"=>48.3,
        "text"=>
         "Morkel to Ashwin, no run, exposes all his stumps and looks to ramp this short ball, too quick for him, and he was on the move, didn't have a stable base to play the shot from",
        "players"=>
         {"players"=>
           [{"name"=>"Morkel", "photo"=>"http://test.com/Morkel.png"},
            {"name"=>"Ashwin", "photo"=>"http://test.com/Ashwin.png"}]}}]}

     expect(expected_result).to eq(result)
  end
end
