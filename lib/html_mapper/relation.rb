module HtmlMapper
  class Relation
    attr_reader :name, :klass, :options

    def initialize(name, klass, options = {})
      @name = name.to_sym
      @klass = klass.is_a?(String) ? string_to_constant(klass) : klass
      @options = options
    end

    def parse(doc, parent)
      klass.parse(doc).tap do |obj|
        parent[name] = obj
        obj.parent = parent
      end
    end

    def as_json
      {
        name:    name,
        klass:   klass.name,
        options: options,
        mapper:  klass.as_json
      }
    end

    private

    def string_to_constant(type)
      names = type.split('::')
      constant = Object
      names.each do |name|
        constant = if constant.const_defined?(name)
                     constant.const_get(name)
                   else
                     constant.const_missing(name)
                   end
      end
      constant
    end

  end
end
