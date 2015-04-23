source 'https://rubygems.org'

# Specify your gem's dependencies in html_mapper.gemspec
gemspec

group :docs do
  gem 'yard', :git => 'https://github.com/trevorrowe/yard.git', branch: 'frameless'
  gem 'yard-sitemap', '~> 1.0'
  gem 'rdiscount'

  gem 'nanoc' # guide

  # guide - syntax highlight
  gem 'nokogiri'
  gem 'coderay'

  # guide - local preview
  gem 'adsf' # a dead simple fileserver
  gem 'guard-nanoc'
end

group :repl do
  gem 'pry'
end

#require './debug.rb'
