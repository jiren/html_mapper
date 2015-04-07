module HtmlMapper
  class Collection
    attr_accessor :selector, :name, :fields, :relations, :options

    def initialize(name, selector)
      @selector = selector
      @name = name.to_sym
      @fields = []
      @relations = []
      @options = {}
    end

    def process(doc, obj)
      eles = doc.search(selector).reject { |ele| exec_reject_if(ele, obj) }

      if options[:single]
        find(eles.first, obj)
      else
        eles.map { |ele| find(ele, obj) }
      end
    end

    def find(doc, obj)
      return nil if doc.nil?

      result = Result.new(name)

      @fields.each do |field|
        result[field.name] = field.find(doc, obj)
      end

      @relations.each do |relation|
        result[relation[:name]] = relation[:klass].parse(doc)
      end

      result
    end

    def new_field(name, selector, options)
      Field.new(name, selector, options).tap do |field|
        @fields << field
      end
    end

    def new_relation(name, klass, options)
      name = name.to_sym

      @relations << {
        klass: klass.is_a?(String) ? string_to_constant(klass) : klass,
        options: options,
        name: name
      }
    end

    def exec_reject_if(ele, obj)
      return false if options[:reject_if].nil?

      if options[:reject_if].is_a?(Symbol)
        obj.send(options[:reject_if], ele)
      else
        options[:reject_if].call(ele)
      end
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
