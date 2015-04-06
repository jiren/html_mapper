module HtmlMapper
  class Field
    attr_accessor :name, :type, :selector, :options
    attr_reader :multiple

    def initialize(name, selector, options = {})
      @name = name
      @selector = selector.split(',')
      @options = options

      @multiple = @name.is_a?(Array)
    end

    def find(doc, obj)
      ele = nil
      selector.each do |s| 
        ele = doc.search(s).first 
        break if ele
      end

      value = ele && process_ele(ele, obj) 
      
      options[:as] ? typecast(value) : value 
    end

    def typecast(value)
      SupportedTypes.types[options[:as]].apply(value)
    end

    private

    def process_ele(ele, obj)
      value = options[:attribute] ? ele.attributes[options[:attribute]].to_s : ele.content

      return nil unless value

      value.strip!
        
      if options[:eval]
        options[:eval].is_a?(Symbol) ? obj.send(options[:eval], value, ele) : options[:eval].call(value, ele)
      else
        value
      end
    end
  end
end
