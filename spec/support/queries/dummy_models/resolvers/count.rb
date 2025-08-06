# frozen_string_literal: true

module DummyModels
  module Resolvers
    class Count < ActiveQuery::Resolver
      def resolve
        scope.count
      end
    end
  end
end
