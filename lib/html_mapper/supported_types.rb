module HtmlMapper
  class Boolean; end

  module SupportedTypes
    module_function

    def types
      @types ||= {}
    end

    def register_type(type, typecaster_obj = nil, &block)
      types[type] = typecaster_obj || CastWhenType.new(type, &block)
    end

    def find_by_name(type)
      typecaster = SupportedTypes.types.find{|k, _| k.name == type }
      typecaster ? typecaster.first : nil
    end

    class CastWhenType
      attr_reader :type

      def initialize(type, &block)
        @type = type
        @apply_block = block || no_operation
      end

      def no_operation
        ->(value) { value }
      end

      def apply?(_value, convert_to_type)
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

      def apply?(value, convert_to_type)
        value.is_a?(convert_to_type) || value.nil?
      end

      def apply(value)
        value
      end
    end

    register_type NilOrAlreadyConverted, NilOrAlreadyConverted.new

    register_type String do |value|
      value.to_s
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

    BOOL_TYPES = %w(true t 1)

    register_type Boolean do |value|
      BOOL_TYPES.include?(value.to_s.downcase)
    end

    DIGIT_REGX = /^\d+/

    register_type Integer do |value|
      value_to_i = value.to_i

      if value_to_i == 0 && !(value.to_s =~ DIGIT_REGX)
        nil
      else
        value_to_i
      end
    end

    register_type Float do |value|
      value_to_f = value.to_f

      if value_to_f == 0.0 && !(value.to_s =~ DIGIT_REGX)
        nil
      else
        value_to_f
      end
    end

  end
end
