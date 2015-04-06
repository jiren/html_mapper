$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'html_mapper'

def fixture_file(filename)
  File.read(File.dirname(__FILE__) + "/fixtures/#{filename}")
end
