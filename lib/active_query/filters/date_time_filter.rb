# frozen_string_literal: true

require 'date'

module ActiveQuery
  module Filters
    class DateTimeFilter < Base
      private

      def accepted_classes
        classes = [DateTime, Time]
        classes << ActiveSupport::TimeWithZone if defined?(ActiveSupport::TimeWithZone)
        classes
      end

      def cast(value)
        case value
        when String
          DateTime.parse(value)
        when Date
          value.to_datetime
        else
          raise ArgumentError, ":#{name} must be of type DateTime"
        end
      rescue ::Date::Error
        raise ArgumentError, ":#{name} must be of type DateTime"
      end
    end
  end
end
