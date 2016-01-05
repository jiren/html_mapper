module HtmlMapper
  module MapperExporter
    module_function

    def export(klass)
      mapper = {
        domains: klass.domain_list,
        collections: klass.collections.map { |_, c| c.as_json }
      }

      if klass.default_collection
        mapper[:collections] << klass.default_collection.as_json
      end

      mapper
    end

    def new_scraper(domain_list = nil)
      Class.new do
        include HtmlMapper
        domains(domain_list) if domain_list
      end
    end

    def to_mapper(mapper)
      klass = new_scraper(mapper[:domains])

      mapper[:collections].map do |c|
        klass.collections[c[:name].to_sym] = build_collection(c)
      end

      klass
    end

    def build_collection(data)
      data[:options] = {} unless data[:options]
      collection = Collection.new(data[:name].to_sym, data[:selector], data[:options])

      data[:fields].each { |f| add_field(collection, f) }
      data[:relations].each { |r| add_realtion(collection, r) }

      collection
    end

    def add_field(collection, field)
      field[:options] = {} unless field[:options]

      if field[:options][:as]
        field[:options][:as] = SupportedTypes.find_by_name(field[:options][:as])
      end

      collection.new_field(field[:name], field[:selector], field[:options])
    end

    def add_realtion(collection, relation)
      relation_klass = to_mapper(relation[:mapper])
      collection.new_relation(relation[:name].to_sym, relation_klass, relation[:options] || {})
    end
  end
end
