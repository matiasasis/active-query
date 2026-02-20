# frozen_string_literal: true

module ActiveQuery
  module Filters
    class StringFilter < Base
      private

      def accepted_classes
        [String]
      end

      def cast(value)
        value.to_s
      end
    end
  end
end
