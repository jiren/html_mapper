require 'rails/generators/named_base'

module HtmlMapper
  module Generators # :nodoc:
    class ScraperGenerator < ::Rails::Generators::NamedBase # :nodoc:
      desc 'This generator creates a HtmlMapper Scraper in app/scrapers and a corresponding test'

      check_class_collision suffix: 'Scraper'

      def self.default_generator_root
        File.dirname(__FILE__)
      end

      def create_scraper_file
        template 'scraper.rb.erb', File.join('app/scrapers', class_path, "#{file_name}_scraper.rb")
      end

      def create_test_file
        if defined?(RSpec)
          create_scraper_spec
        else
          create_scraper_test
        end
      end

      private

      def create_scraper_spec
        template_file = File.join(
            'spec/scrapers',
            class_path,
            "#{file_name}_scraper_spec.rb"
        )
        template 'scraper_spec.rb.erb', template_file
      end

      def create_scraper_test
        template_file = File.join(
            'test/scrapers',
            class_path,
            "#{file_name}_scraper_test.rb"
        )
        template 'scraper_test.rb.erb', template_file
      end
    end
  end
end
