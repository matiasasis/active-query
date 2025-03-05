# frozen_string_literal: true

module ActiveQuery
  class Resolver
    attr_accessor :scope

    def initialize(scope)
      @scope = scope
    end
  end
end
