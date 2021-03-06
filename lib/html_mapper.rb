require 'nokogiri'
require 'rest_client'
require 'date'
require 'time'
require 'json'

require 'html_mapper/version'
require 'html_mapper/parsers'
require 'html_mapper/supported_types'
require 'html_mapper/collection'
require 'html_mapper/relation'
require 'html_mapper/field'
require 'html_mapper/object_helper'
require 'html_mapper/result'
require 'html_mapper/mapper_exporter'

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
    # It select parser based on given url and parse page.
    #
    #     HtmlMapper.parse('http://www.imdb.com/search/title?count=100', HTML content of given url)
    #
    def parse(url, html)
      parsers = Parsers.get(url)

      if parsers
        parsers.map { |klass| klass.parse(Nokogiri::HTML.parse(html), url) }
      else
        fail NotFoundError, "No parser found for #{url}"
      end
    end

    #
    # @params [RestClient] http_client
    #   Set other http client like httparty etc
    #
    attr_writer :http_client

    #
    # @return [RestClient]
    #
    def http_client
      @http_client || RestClient
    end

    # @params [String] url
    def get(url)
      html = http_client.get(url)
      parse(url, html)
    end

    def to_mapper(mapper_json)
      MapperExporter.to_mapper(JSON.parse(mapper_json,  { symbolize_names: true }))
    end
  end

  extend ModuleMethods

  module ClassMethods
    attr_reader :collections, :default_collection

    def domains(*args)
      args.each { |domain| Parsers.add(self, domain) }
      @domains = args
    end

    def domain_list
      @domains
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

    def as_json
      MapperExporter.export(self)
    end

    def to_json
      as_json.to_json
    end

    #
    # @param [String] dir
    #   Output directory name
    # @param [String] url
    #   Web page url
    # @param [String] html
    #   Optional
    #
    def export_mapper_with_data(dir, url, html = nil)
      file = File.join(dir, to_s)

      File.write("#{file}.mapper", JSON.pretty_generate(as_json))
      data = get(url, html)
      File.write("#{file}.data", data.to_json)
    end

    private

    def current_collection
      @current_collection ||
        (@default_collection ||= Collection.new(:_default, '.', {}))
    end
  end

  module InstanceMethods
    # @return [String, nil] Url
    attr_accessor :crawl_url

    def initialize
      @values = {}
    end
  end
end
