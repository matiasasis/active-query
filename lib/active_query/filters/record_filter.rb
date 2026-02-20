# frozen_string_literal: true

module ActiveQuery
  module Filters
    class RecordFilter < Base
      def process(value)
        return value if value.nil?

        klass = record_class
        return value if value.is_a?(klass)

        cast(value)
      end

      private

      def accepted_classes
        [record_class]
      end

      def record_class
        @record_class ||= begin
          klass = options[:class] || options[:type]
          case klass
          when String
            klass.constantize
          when Class
            klass
          else
            raise ArgumentError, ":#{name} requires a valid class option for record type"
          end
        end
      end

      def cast(value)
        case value
        when String, Integer
          record_class.find(value)
        else
          raise ArgumentError, ":#{name} must be of type #{record_class}"
        end
      rescue ActiveRecord::RecordNotFound
        raise ArgumentError, ":#{name} record not found with id: #{value}"
      end
    end
  end
end
