# frozen_string_literal: true

require 'date'

module ActiveQuery
  module Filters
    class DateFilter < Base
      def process(value)
        return value if value.nil?
        return value if value.instance_of?(Date)

        cast(value)
      end

      private

      def accepted_classes
        [Date]
      end

      def cast(value)
        case value
        when String
          Date.parse(value)
        when Time, DateTime
          value.to_date
        else
          raise ArgumentError, ":#{name} must be of type Date"
        end
      rescue ::Date::Error
        raise ArgumentError, ":#{name} must be of type Date"
      end
    end
  end
end
