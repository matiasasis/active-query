# frozen_string_literal: true

module DummyModels
  module Resolvers
    class ByName < ActiveQuery::Resolver
      def resolve(name:)
        scope.where(name: name)
      end
    end
  end
end
