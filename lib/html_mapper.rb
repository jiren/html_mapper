require 'nokogiri'
require 'rest_client'
require 'date'
require 'time'
require 'json'

require 'html_mapper/version'
require 'html_mapper/parser_map'
require 'html_mapper/supported_types'
require 'html_mapper/collection'
require 'html_mapper/field'
require 'html_mapper/object_helper'
require 'html_mapper/result'

module HtmlMapper
  class NotFound < StandardError; end

  def self.included(base)
    base.instance_eval do
      @collections = {} 
    end

    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.send :include, ObjectHelper
  end

  module ModuleMethods

    def parse(url, html)
      parser = ParserMap.get(url)

      if parser
        parser.parse(Nokogiri::HTML.parse(html))
      else
        raise NotFound.new("No parser found for #{url}")
      end
    end

    def http_client=(client)
      @http_client = client
    end

    def http_client
      @http_client || RestClient
    end

    def fetch_and_parse(url)
      html = http_client.get(url)
      parse(url, html)
    end
  end

  self.extend ModuleMethods

  module ClassMethods

    def domains(*args)
      args.each{|domain| ParserMap.add(self, domain)}
    end

    def collection(name, selector, options = {})
      name = name.to_sym
      @collections[name] = @current_collection = Collection.new(selector, name)
      @current_collection.options = options

      yield if block_given?

      @current_collection = nil
      attr_accessor name
    end

    def field(name, selector, options = {})
      current_collection.new_field(name, selector, options)
    end

    def has_many(name, klass, options = {})
      relation(name, klass, options.merge!(many: true))
    end

    def has_one(name, klass, options = {})
      relation(name, klass, options.merge!(many: false))
    end

    def parse(doc)
      obj = self.new
   
      @collections.each do |name, collection|
        eles = doc.search(collection.selector).reject do |ele|
          collection.exec_reject_if(ele, obj)
        end

        results = if collection.options[:single]
                    collection.find(eles.first, obj)
                  else
                    eles.collect { |ele| collection.find(ele, obj) }
                  end
        obj[name] = results
      end

      #TODO : Default collection
      obj
    end

    def fetch_and_parse(url, html = nil)
      html = html || HtmlMapper.http_client.get(url)
      parse(Nokogiri::HTML.parse(html))
    end

    private

    def relation(name, klass, options)
      #if block_given?
      #  options = klass
      #  klass = Class.new{ include HtmlMapper }
      #  yield klass
      #end

      current_collection.new_relation(name, klass, options)
    end

    def current_collection
      @current_collection || (@default_collection ||= Collection.new(:default, '.'))
    end

  end

  module InstanceMethods
    def initialize
      @values = {}
    end
  end

end
