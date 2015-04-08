require 'nokogiri'
require 'rest_client'
require 'date'
require 'time'
require 'json'

require 'html_mapper/version'
require 'html_mapper/parser_map'
require 'html_mapper/supported_types'
require 'html_mapper/collection'
require 'html_mapper/relation'
require 'html_mapper/field'
require 'html_mapper/object_helper'
require 'html_mapper/result'

module HtmlMapper
  class NotFoundError < StandardError; end

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
        parser.parse(Nokogiri::HTML.parse(html), url)
      else
        fail NotFoundError, "No parser found for #{url}"
      end
    end

    attr_writer :http_client

    def http_client
      @http_client || RestClient
    end

    def get(url)
      html = http_client.get(url)
      parse(url, html)
    end
  end

  extend ModuleMethods

  module ClassMethods
    def domains(*args)
      args.each { |domain| ParserMap.add(self, domain) }
    end

    def collection(name, selector, options = {})
      name = name.to_sym
      @current_collection = @collections[name] = Collection.new(name, selector, options)

      yield if block_given?

      @current_collection = nil
    end

    def field(name, selector, options = {})
      current_collection.new_field(name, selector, options)
    end

    def has_many(name, klass, options = {})
      current_collection.new_relation(name, klass, options.merge!(many: true))
    end

    def has_one(name, klass, options = {})
      current_collection.new_relation(name, klass, options.merge!(many: false))
    end

    def parse(doc, url = nil)
      doc = Nokogiri::HTML.parse(doc) if doc.is_a?(String)
      obj = new
      obj.crawl_url = url

      @collections.each do |name, collection|
        obj[name] = collection.process(doc, obj)
      end

      if @default_collection
        obj[@default_collection.name] = @default_collection.process(doc, obj)
      end

      @callbacks.each { |c| obj.send(c) } if @callbacks

      obj
    end

    def get(url, html = nil)
      html = HtmlMapper.http_client.get(url) unless html
      parse(Nokogiri::HTML.parse(html), url)
    end

    def after_process(*args)
      @callbacks ||= []
      args.each { |callback| @callbacks << callback.to_sym }
    end

    private

    def current_collection
      @current_collection ||
        (@default_collection ||= Collection.new(:_default, '.', {}))
    end
  end

  module InstanceMethods
    attr_accessor :crawl_url

    def initialize
      @values = {}
    end
  end
end
