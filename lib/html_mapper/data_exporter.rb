require 'csv'

module HtmlMapper
  module DataExporter

    def csv_fields(*args)
      @csv_fields = args
    end

    def to_csv
    end
  end
end
