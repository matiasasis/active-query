# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'

module ActiveQuery
  module Filters
    class DecimalFilter < Base
      private

      def accepted_classes
        [BigDecimal]
      end

      def cast(value)
        BigDecimal(value.to_s)
      rescue ::ArgumentError, ::TypeError
        raise ArgumentError, ":#{name} must be of type Decimal"
      end
    end
  end
end
