module HtmlMapper
  class Field
    attr_accessor :name, :type, :selector, :options

    def initialize(name, selector, options = {})
      @name = name
      @selector = selector
      @options = options
    end

    def find(doc, obj)
      eles = doc.search(selector)

      if options[:all]
        eles.map{|ele| find_values(obj, ele)}.compact
      else
        find_values(obj, eles.first)
      end
    end

    def typecast(value)
      SupportedTypes.types[options[:as]].apply(value)
    end

    def as_json
      h = { name: name, selector: selector }

      if options.any?
        h[:options] = options
        h[:options][:as] = options[:as].name if options[:as]
        h[:options].delete(:eval) if options[:eval].is_a?(Proc)
      end

      return h
    end

    private

    def find_values(obj, ele)
      if ele
        value = process_ele(ele, obj)
        options[:as] ? typecast(value) : value
      end
    end

    def process_ele(ele, obj)
      value = if options[:attribute]
                ele.attributes[options[:attribute]].to_s
              else
                ele.content
              end

      value.strip!
      return value unless options[:eval]

      if options[:eval].is_a?(Symbol)
        obj.send(options[:eval], value, ele)
      else
        options[:eval].call(value, ele)
      end
    end
  end
end
