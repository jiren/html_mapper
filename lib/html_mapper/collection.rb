module HtmlMapper
  class Collection
    attr_accessor :selector, :name, :fields, :relations, :options

    def initialize(name, selector, options)
      @selector = selector
      @name = name.to_sym
      @fields = []
      @relations = []
      @options = options
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
      result.parent = obj

      @fields.each do |field|
        result[field.name] = field.find(doc, obj)
      end

      @relations.each do |relation|
        relation.parse(doc, result)
      end

      result
    end

    def new_field(name, selector, options)
      Field.new(name, selector, options).tap do |field|
        @fields << field
      end
    end

    def new_relation(name, klass, options)
      @relations << Relation.new(name, klass, options)
    end

    def exec_reject_if(ele, obj)
      return false if options[:reject_if].nil?

      if options[:reject_if].is_a?(Symbol)
        obj.send(options[:reject_if], ele)
      else
        options[:reject_if].call(ele)
      end
    end

    def as_json
      {
        name: name,
        selector: selector,
        options: options,
        fields: fields.map(&:as_json),
        relations: relations.map(&:as_json)
      }
    end

  end
end
