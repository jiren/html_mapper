module HtmlMapper
  class Field
    attr_accessor :name, :type, :selector, :options

    def initialize(name, selector, options = {})
      @name = name
      @selector = selector.split(',')
      @options = options
    end

    def find(doc, obj)
      ele = nil
      selector.each do |s|
        ele = doc.search(s).first
        break if ele
      end

      value = ele ? process_ele(ele, obj) : nil
      options[:as] ? typecast(value) : value
    end

    def typecast(value)
      SupportedTypes.types[options[:as]].apply(value)
    end

    private

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
