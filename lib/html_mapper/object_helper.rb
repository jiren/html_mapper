module HtmlMapper
  module ObjectHelper
    def self.included(base)
      base.send :include, Enumerable
    end

    def [](f)
      @values[f]
    end

    def []=(f, v)
      @values[f] = v
    end

    def to_s(*args)
      JSON.pretty_generate(@values)
    end

    def to_json(*args)
      JSON.generate(@values)
    end

    def as_json(*args)
      @values.as_json(*args)
    end

    def each(&blk)
      @values.each(&blk)
    end

    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}:#{@name}> JSON: #{JSON.pretty_generate(@values)}"
    end

    def method_missing(name, *args, &block)
      @values[name]
    end

  end
end
