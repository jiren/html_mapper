require 'bundler/setup'
require 'html_mapper'

class Batsman
  include HtmlMapper

  collection :stats, 'tr', reject_if: :invalid? do
    field :name, '.batsman-name'
    field :profile_url, '.batsman-name a', attribute: 'href'
    field :dismissal_info, '.dismissal-info'
    field :runs, 'td[4]', as: Integer
    field :minutes, 'td[5]', as: Integer
    field :balls, 'td[6]', as: Integer
    field :fours, 'td[7]', as: Integer
    field :sixes, 'td[8]', as: Integer
    field :strike_rate, 'td[9]', as: Float
  end

  def invalid?(ele)
    !ele.attributes['class'].to_s.empty? 
  end
end

class Bowler
  include HtmlMapper

  collection :stats, 'tr', reject_if: :invalid? do
    field :name,    '.bowler-name'
    field :overs,   'td[3]', as: Float
    field :maiden,  'td[4]', as: Integer
    field :runs,    'td[5]', as: Integer
    field :wickets, 'td[6]', as: Integer
    field :economy, 'td[7]', as: Float
    field :zeros,   'td[8]', as: Integer
    field :fours,   'td[9]', as: Integer
    field :sixes,   'td[10]', as: Integer
  end

  def invalid?(ele)
    !ele.attributes['class'].to_s.empty? 
  end

end

class MatchInformation
  include HtmlMapper

  domains 'http://www.espncricinfo.com'

  collection :summery, '.brief-summary', single: true do
    field :tournament, '.headLink:nth(1)'
    field :season, '.headLink:nth(2)', eval: :parse_season 
    field :venue, '.headLink:nth(3)'
    field [:date, :type, :overs], '.space-top-bottom-5:last', eval: :parse_detail
  end

  collection :battings, 'table.batting-table' do
    field :team, '.th-innings-heading', eval: ->(text, ele) { text.split('innings').first.strip }
    has_many :batsman_stats, 'Batsman'
  end

  collection :bowlings, 'table.bowling-table' do
    has_many :bowlder_stats, 'Bowler'
  end

  def parse_season(text, ele)
    text.split(' ').first
  end

  DETAIL_REGX = /(.*) - (.*) match \((\d+)-/

  def parse_detail(text, ele)
    if detail = text.match(DETAIL_REGX)
      detail.to_a[1..3] 
    end
  end
end

html = File.read(File.dirname(__FILE__) + "/scorecard.html")
puts MatchInformation.parse(Nokogiri::HTML.parse(html)).inspect
