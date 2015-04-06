module HtmlMapper
  class Boolean; end

  module SupportedTypes
    extend self

    def types
      @types ||= {}
    end

    def register_type(type, typecaster_obj = nil, &block)
      types[type] = typecaster_obj || CastWhenType.new(type,&block)
    end

    class CastWhenType
      attr_reader :type

      def initialize(type,&block)
        @type = type
        @apply_block = block || no_operation
      end

      def no_operation
        lambda {|value| value }
      end

      def apply?(value,convert_to_type)
        convert_to_type == type
      end

      def apply(value)
        @apply_block.call(value)
      end
    end

    class NilOrAlreadyConverted

      def type
        NilClass
      end

      def apply?(value,convert_to_type)
        value.kind_of?(convert_to_type) || value.nil?
      end

      def apply(value)
        value
      end
    end

    register_type NilOrAlreadyConverted, NilOrAlreadyConverted.new

    register_type String do |value|
      value.to_s
    end

    register_type Float do |value|
      value.to_f
    end

    register_type Time do |value|
      Time.parse(value.to_s) rescue Time.at(value.to_i)
    end

    register_type Date do |value|
      Date.parse(value.to_s)
    end

    register_type DateTime do |value|
      DateTime.parse(value.to_s)
    end

    register_type Boolean do |value|
      ['true', 't', '1'].include?(value.to_s.downcase)
    end

    register_type Integer do |value|
      value_to_i = value.to_i
      if value_to_i == 0 && value != '0'
        value_to_s = value.to_s
        begin
          Integer(value_to_s =~ /^(\d+)/ ? $1 : value_to_s)
        rescue ArgumentError
          nil
        end
      else
        value_to_i
      end
    end

  end
end
