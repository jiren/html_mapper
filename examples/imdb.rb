require 'bundler/setup'
require 'html_mapper'

class ImDb
  include HtmlMapper

  domains 'www.imdb.com'

  collection :movies, '.list.detail .list_item' do
    field :name, 'b a'
    field :image, '.image img', attribute: 'src'
    field :year, 'b span', eval: ->(t, e){ t.gsub(/[\(\)]/, '') }
    field :rating, '.rating-rating .value', as: Float
    field :desc, '.item_description'
    field :minutes, '.item_description', as: Integer, eval: :to_minutes
    field :director, '.info', eval: :parse_director
    field :stars, '.info', eval: :parse_stars
    field :awards, '.description', eval: :parse_awards
  end

  def parse_names(text, ele)
    ele.search('.secondary')[0].search('a').map(&:text)
  end

  def parse_stars(text, ele)
    ele.search('.secondary')[1].search('a').map(&:text)
  end

  def to_minutes(text, ele)
    text.match(/\((.*)\)/)[1]
  end

  def parse_awards(text, ele)
    awards = ele.children.map{|c| c.text.strip }
    awards.select!{|t| t =~ /.+:\s\d+/ }

    awards.inject({}) do |r, t|
      t.split(':').tap{|a| r[a[0]] = a[1].to_i}
      r
    end
  end
end


# Top 250 Movies
url = 'http://www.imdb.com/list/ls055592025/'
html = File.read(File.dirname(__FILE__) + "/ignore/imdb.html")
@movies = HtmlMapper.parse(url, html)

ImDb.export_mapper_with_data('.', url, html)

#HtmlMapper.get(url).each do |movie|
#  puts movie.inspect
#end

#HtmlMapper.parse(url, html).each do |movie|
#  puts movie.as_json
#end
