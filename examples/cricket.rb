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

  def parse_dismissal(text, ele)
    detail = {}

    if text.include?('run out')
      detail[:wicket_type] = :run_out
      detail[:rub_out_by] = text.match(/\((.*)\)/)[1]
    elsif text.include?('lbw')
      detail[:wicket_type] = :lbw
    else
      out = text.match(/c (.*) b (.*)/)

      if out
        detail[:catcher] = out[1]
        detail[:batsman] = out[2]

        if detail[:catcher].include?('sub')
          detail[:sub] = detail[:catcher].match(/sub \((.*)\)/)[1]
        end

      end
    end

    detail
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

  # Default collection
  field :global_tournament ,'.brief-summary .headLink:nth(1)'

  collection :summery, '.brief-summary', single: true do
    field :tournament, '.innings-information a[1]'
    field :season, '.space-top-bottom-5[1] a[2]', eval: :parse_season
    field :venue, '.space-top-bottom-5[2] a[1]'
    field :detail, '.space-top-bottom-5:last', eval: :parse_detail
  end

  collection :battings, 'table.batting-table' do
    field :team, '.th-innings-heading', eval: ->(text, ele) { text.split('innings').first.strip }
    has_many :batsman_stats, 'Batsman'
  end

  collection :bowlings, 'table.bowling-table' do
    has_many :bowler_stats, 'Bowler'
  end

  after_process :count_bowlers

  def parse_season(text, ele)
    text && text.split(' ').first
  end

  DETAIL_REGX = /(.*) - (.*) match \((\d+)-/

  def parse_detail(text, ele)
    if detail = text.match(DETAIL_REGX)
      {date: detail[1], type: detail[2], overs: detail[3].to_f}
    end
  end

  def count_bowlers
    p self.bowlings.collect{ |stats| stats[:bowler_stats][:stats].length }
  end


end

HtmlMapper.http_client = 1

html = File.read(File.dirname(__FILE__) + "/ignore/scorecard.html")
puts MatchInformation.parse(Nokogiri::HTML.parse(html)).inspect

exit(0)

# Fetch and parse from url
url = 'http://www.espncricinfo.com/icc-cricket-world-cup-2015/engine/match/656423.html'
puts HtmlMapper.get(url).inspect
