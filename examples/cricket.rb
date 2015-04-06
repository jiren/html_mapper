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

class Commentary
  include HtmlMapper

  domains 'http://espncrickinfo.com'

  collection :commentary, '.commentary-event' do
    field :overs, '.commentary-overs'
    field :outcome,  '.commentary-text', eval: :parse_commentray
  end

  #tag :latest

  def parse_commentray(text, ele)
    values = text.split(',')

    return nil if values.length < 2

    values = values.collect(&:strip)

    outcome = {commentary: values.join(', ')}

    values[0].split('to').tap do |v|
      outcome[:bowler] = v[0].strip
      outcome[:bastman] = v[1].strip
    end

    run_text = values[1]

    if values[1] == 'OUT'
      outcome[:wicket] = true
      run_text = 'no run'
    elsif values[2] == 'OUT'
      outcome[:wicket] = true
    end

    outcome[:runs] = parse_runs(run_text)

    if RUNS[run_text] == 6
      outcome[:six] = true
    elsif RUNS[run_text] == 4
      outcome[:four] = true
    end

    outcome[:wide] = true if run_text.include?('wide')
    outcome[:no_ball] = true if run_text.include?('no ball')
    outcome[:wicket] = true if run_text == 'OUT'

    outcome
  end

  RUNS = {
    'FOUR' => 4,
    'SIX' => 6,
    'no run' => 0
  }

  def parse_runs(text)
    RUNS[text] || text.match(/\d+/)[0].to_i
  end

end


#html = File.read(File.dirname(__FILE__) + "/cricket1.html")
html = File.read(File.dirname(__FILE__) + "/IN_SA_1.html")

url = 'http://www.espncricinfo.com/icc-cricket-world-cup-2015/engine/match/656423.html?innings=1;view=commentary'

#puts Commentary.fetch_and_parse(url).inspect


#HtmlMapper.parse('http://espncrickinfo.com', html).tap do |cricket|
#  puts cricket.inspect
#end
