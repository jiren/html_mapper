module HtmlMapper
  class Result
    include ObjectHelper

    attr_reader :values, :name

    def initialize(name)
      @name = name
      @values = {}
    end
  end
end
