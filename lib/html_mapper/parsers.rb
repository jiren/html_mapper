module HtmlMapper
  class Parsers
    class << self
      attr_accessor :parsers, :regx_parsers

      def add(klass, domain)
        if domain.is_a?(Regexp)
          (@regx_parsers[domain] ||= []) << klass
        elsif domain.is_a?(String)
          host = URI(domain).host || domain
          (@parsers[host] ||= []) << klass
        end
      end

      def get(url)
        host = URI(url).host

        parser = @parsers[host]
        return parser if parser

        parser = @regx_parsers.find { |k, _| k =~ url }
        return parser.last if parser
      end

      def each(&blk)
        @parsers.each(&blk)
        @regx_parsers.each(&blk)
      end

    end

    self.parsers = {}
    self.regx_parsers = {}
  end
end
