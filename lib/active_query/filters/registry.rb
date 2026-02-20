# frozen_string_literal: true

module ActiveQuery
  module Filters
    module Registry
      SYMBOL_MAP = {}
      CLASS_MAP = {}

      def self.register(symbol, filter_class, *ruby_classes)
        SYMBOL_MAP[symbol] = filter_class
        ruby_classes.each { |klass| CLASS_MAP[klass] = filter_class }
      end

      def self.build(name, type:, **options)
        filter_class = resolve(type, **options)
        filter_class.new(name, **options)
      end

      def self.resolve(type, **options)
        case type
        when Symbol
          SYMBOL_MAP.fetch(type) { raise ArgumentError, "Unknown filter type: #{type}" }
        when Class
          CLASS_MAP.fetch(type) { RecordFilter }
        else
          raise ArgumentError, "Invalid filter type: #{type.inspect}, must be a Symbol or Class"
        end
      end
    end

    Registry.register(:string,    StringFilter,   String)
    Registry.register(:integer,   IntegerFilter,  Integer)
    Registry.register(:float,     FloatFilter,    Float)
    Registry.register(:boolean,   BooleanFilter)
    Registry.register(:date,      DateFilter,     Date)
    Registry.register(:date_time, DateTimeFilter,  DateTime)
    Registry.register(:symbol,    SymbolFilter,   Symbol)
    Registry.register(:decimal,   DecimalFilter,  BigDecimal)
    Registry.register(:record,    RecordFilter)
    Registry.register(:array,     ArrayFilter,    Array)
    Registry.register(:hash,      HashFilter,     Hash)

    module Registry
      # Deferred registration for the legacy Boolean sentinel class.
      # Called after ActiveQuery::Base is defined.
      def self.register_boolean_sentinel!
        CLASS_MAP[ActiveQuery::Base::Boolean] = BooleanFilter
      end
    end
  end
end
