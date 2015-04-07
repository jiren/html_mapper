module HtmlMapper
  class ParserMap
    class << self
      attr_accessor :str_parsers, :regx_parsers

      def _init_
        @regx_parsers = {}
        @str_parsers = {}
      end

      def add(klass, domain)
        if domain.is_a?(Regexp)
          @regx_parsers[domain] = klass
        elsif domain.is_a?(String)
          (URI(domain).host || domain).tap { |host| @str_parsers[host] = klass }
        end
      end

      def get(url)
        host = URI(url).host

        parser = @str_parsers[host]
        return parser if parser

        parser = @regx_parsers.find { |k, _| k =~ url }
        return parser.last if parser
      end
    end

    _init_
  end
end
