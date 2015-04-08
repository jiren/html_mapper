module HtmlMapper
  class Result
    include ObjectHelper

    attr_reader :values, :name
    attr_accessor :parent

    def initialize(name)
      @name = name
      @values = {}
    end
  end
end
