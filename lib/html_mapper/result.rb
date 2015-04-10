module HtmlMapper
  class Result
    include ObjectHelper

    attr_reader :values, :_name
    attr_accessor :parent

    def initialize(name)
      @_name = name
      @values = {}
    end
  end
end
