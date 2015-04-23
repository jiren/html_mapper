module HtmlMapper
  module ExportMapper
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

      data[:fields].each do |f|
        f[:options] = {} unless f[:options]

        if f[:options][:as]
          f[:options][:as] = SupportedTypes.find_by_name(f[:options][:as])
        end

        collection.new_field(f[:name], f[:selector], f[:options])
      end

      data[:relations].each do |r|
        relation_klass = to_mapper(r[:mapper])
        collection.new_relation(r[:name].to_sym, relation_klass, r[:options] || {})
      end

      collection
    end
  end
end
